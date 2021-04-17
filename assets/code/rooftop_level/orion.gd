#-----------------------------------------------------------------------------#
# File Name:   	orion.gd                                                      #
# Description: 	Controls the throwing of the spear projectile and animations  #
# Author:      	Andrew Zedwick (mostly) & Jeff Newell                         #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 21th, 2020                                           #
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
export var ai_enabled:     bool  = true
# Number of seconds before Orion throws a spear
export var throw_cooldown: float = 2.0

export var health: int = 3
export var damage: int = 1

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since Orion last threw a spear
var _throw_update_time: float = 0.0
# Number of seconds since Orion began playing his throwing animation
var _throw_anim_time: 	float = throw_cooldown / 2


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy(health, damage, 0.0, 0.0)
	$AnimatedSprite.play("idle")

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_throw_update_time += delta
		
		if _throw_update_time >= throw_cooldown:
			# Animate orion to throw the spear
			$AnimatedSprite.play("throw")
			if $AnimatedSprite.animation == "throw" and $AnimatedSprite.frame >= $AnimatedSprite.frames.get_frame_count("throw") - 3:
				_spawn_spear()
		elif $AnimatedSprite.animation != "idle":
			$AnimatedSprite.play("idle")

# Spawns and propels a spear
func _spawn_spear() -> void:
	# Create, initialize, and add a new spear projectile
	var spear = SPEAR.instance()
	get_node("/root").add_child(spear)
	spear.global_position = $spear_spawn.global_position
	spear.initialize()
	
	# Reset the _throw_update time now that the spear has been spawned
	_throw_update_time = 0.0
	
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Orion_collision(_body):
	pass # Replace with function body.

func _on_Orion_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.set_deferred("disabled", true)

	timer.set_one_shot(true)
	add_child(timer)
	
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()

func _on_Orion_health_changed(ammount):
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
