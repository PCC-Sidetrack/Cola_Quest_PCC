#-----------------------------------------------------------------------------#
# File Name:    pterodactyl.gd                                                #
# Description:            #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: March 29, 2021                                                #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
# Holds a reference to the gust_projectile scene
const GUST = preload("res://assets/sprite_scenes/cc_scenes/gust_projectile.tscn")

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:         bool  = true
# Movement speed
export var movement_speed:     float = 1.875
# Number of seconds before a pterodactyl throws a gust attack
export var throw_cooldown:     float = 3
# Seconds of movement before changing directions
export var turnaround_time:    float = 5.0
# Start facing right?
export var start_moving_right: bool  = true
export var health:             int   = 1
export var damage:             int   = 1
export var acceleration:       float = 20.0
export var knockback:          float = 0.8

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Used to check if the drone can currently shoot
var _shoot_enabled:        bool = true
# Number of seconds since Orion last threw a spear
var _throw_update_time: float = 0.0

var is_player_in_range: bool = false

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	# Holds the ai instructions
	var instructions: Array

	# Set the ai instructions based on which initial direction the bird is moving
	instructions = [
		duration (Vector2.RIGHT if start_moving_right else Vector2.LEFT, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions    (instructions, true)
	initialize_enemy           (health, damage, movement_speed, acceleration)
	set_knockback_multiplier   (knockback)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("fly")
	$healthbar.max_value = health

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_throw_update_time += delta
		
		if _throw_update_time >= throw_cooldown and is_player_in_range:
			# Animate orion to throw the spear
			#$AnimatedSprite.play("throw")
			#if $AnimatedSprite.animation == "throw" and $AnimatedSprite.frame >= $AnimatedSprite.frames.get_frame_count("throw") - 3:
			if (Globals.player_position.x - self.global_position.x > 0 and get_direction_facing() == 1) or (Globals.player_position.x - self.global_position.x < 0 and get_direction_facing() == -1) and is_player_in_range:
				_spawn_gust()
		move()

# Spawns and propels a gust attack
func _spawn_gust() -> void:
	# Create, initialize, and add a new gust projectile
	var gust = GUST.instance()
	#$gust_spawn.add_child(gust)
	get_node("/root").add_child(gust)
	gust.global_position = $gust_spawn.global_position
	gust.initialize()

	# Reset the _throw_update time now that the spear has been spawned
	_throw_update_time = 0.0

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the pterodactyl dies
func _on_pterodactyl_death() -> void:
	# Used to wait a given amount of time before deleting the entity
	ai_enabled = false
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	var timer: Timer = Timer.new()
	
	set_collision_mask(0)
	set_collision_layer(0)
	timer.set_one_shot(true)
	add_child(timer)
	
	$sword_hit.play()
	death_anim (10, 0.05)
	timer.start(10 * 0.05)
	yield(timer, "timeout")
	queue_free()

# Triggered whenever the pterodactyl's health is changed
func _on_pterodactyl_health_changed(amount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true

	if amount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		is_player_in_range = true

func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		is_player_in_range = false


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		_knockback_old(body)
		custom_knockback(self, 2.0, -global_position.direction_to(Globals.player_position))
