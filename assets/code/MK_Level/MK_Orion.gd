#-----------------------------------------------------------------------------#
# File Name:   	orion.gd                                                      #
# Description: 	Contols the MK_Orion enemy                                    #
# Author:      	Luke Hathcock                                                 #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 20, 2021                                                #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
const SPEAR = preload("res://assets//sprite_scenes//rooftop_scenes//spear.tscn")


#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var can_throw:     bool  = true
# Number of seconds before Orion throws a spear
export var throw_cooldown: float = 1.0

export var health: int = 2
export var damage: int = 1

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since Orion last threw a spear
var _throw_update_time: float = 0.0
# Number of seconds since Orion began playing his throwing animation
var _throw_anim_time: 	float = throw_cooldown / 2
var move_time = .5
var check_health = health

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	
	var instructions = [
		duration (Vector2.LEFT + Vector2.UP, move_time),
		duration (Vector2.RIGHT + Vector2.UP, move_time),
		duration (Vector2.RIGHT + Vector2.DOWN, move_time),
		duration (Vector2.LEFT + Vector2.DOWN, move_time),
		end_point(global_position)
	]
	initialize_instructions (instructions, true)
	
	initialize_enemy(health, damage, 3, 16.0)
	$AnimatedSprite.play("idle")
	
	$healthbar.max_value = health
	
		
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if can_throw:
		_throw_update_time += delta
		
		if _throw_update_time >= throw_cooldown:
			# Animate orion to throw the spear
			$AnimatedSprite.play("throw")
			if $AnimatedSprite.animation == "throw" and $AnimatedSprite.frame >= $AnimatedSprite.frames.get_frame_count("throw") - 3:
				_spawn_spear()
		elif $AnimatedSprite.animation != "idle":
			$AnimatedSprite.play("idle")
	move()

# Spawns and propels a spear
func _spawn_spear() -> void:
	# Create, initialize, and add a new spear projectile
	var spear = SPEAR.instance()
	get_node("/root").add_child(spear)
	spear.global_position = $spear_spawn.global_position
	spear.initialize()
	
	# Reset the _throw_update time now that the spear has been spawned
	_throw_update_time = 0.0
	
func play_sound(var sound, var length):
	var t = Timer.new()
	t.set_wait_time(length)
	t.set_one_shot(true)
	self.add_child(t)
	sound.play()
	t.start()
	yield(t, "timeout")
	sound.stop()
	
func spin_sprite():
	var timer: Timer = Timer.new()
	for i in 1000:
		timer.set_one_shot(true)
		add_child(timer)
		timer.start(0.01)
		yield(timer, "timeout")
		$AnimatedSprite.rotation_degrees = $AnimatedSprite.rotation_degrees + 30
		i += 1
	
func set_initial_direction_moving(direction: Vector2 = Vector2.DOWN) -> void:
	var instructions = [
		duration (direction, move_time),
		end_point(global_position)
	]
	
	initialize_instructions (instructions, true)
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Orion_collision(_body):
	pass

func _on_Orion_death():
	var timer: Timer = Timer.new()

	set_collision_mask(0)
	set_collision_layer(0)
	$Dmg_Player.set_collision_layer(0)
	spin_sprite()
	can_throw = false
	play_sound($Hurt, .75)
	
	timer.set_one_shot(true)
	add_child(timer)
	death_anim (25,  0.04)
	timer.start(25 * 0.04)
	yield(timer, "timeout")
	
	queue_free()

func _on_Orion_health_changed(_change):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if health > 0:
		play_sound($Hurt, .75)
		flash_damaged(10)
	check_health = check_health - 1
	
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")



func _on_Dmg_Player_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		if check_health:
			body.knockback(self)
			deal_damage(body)
			
# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 
