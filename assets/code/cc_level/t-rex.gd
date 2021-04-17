#-----------------------------------------------------------------------------#
# File Name:   	bird.gd                                                       #
# Description: 	Directs the animation and ai for the bird sprite              #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 12th, 2020                                           #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Movement speed
export var movement_speed:     float = 1.5
# Start facing right?
export var start_moving_right: bool  = true
export var health:             int   = 1
export var damage:             int   = 1
export var accelertion:        float = 20.0
export var knockback:          float = 0.8
export var jump_velocity:      float   = 0.0
export var obeys_gravity:      bool    = true
export var initial_direction: Vector2 = Vector2.RIGHT
export onready var floor_checker       = get_node("floor_checker")

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: Vector2 = initial_direction

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, movement_speed, accelertion, jump_velocity, obeys_gravity)
	set_knockback_multiplier   (knockback)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("walk")
	$healthbar.max_value = health


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(_delta: float) -> void:
	if !floor_checker.is_colliding():
		_direction = -_direction
		if floor_checker.get_cast_to() == Vector2(-floor_checker.cast_to.x, floor_checker.cast_to.y):
			floor_checker.set_cast_to(Vector2(floor_checker.cast_to.x, floor_checker.cast_to.y))
		else:
			floor_checker.set_cast_to(Vector2(-floor_checker.cast_to.x, floor_checker.cast_to.y))
	move_dynamically(_direction)
	
	# Change the direction if the entity hits a wall
	if is_on_wall():
		_direction = -_direction
		if floor_checker.get_cast_to() == Vector2(-floor_checker.cast_to.x, floor_checker.cast_to.y):
			floor_checker.set_cast_to(Vector2(floor_checker.cast_to.x, floor_checker.cast_to.y))
		else:
			floor_checker.set_cast_to(Vector2(-floor_checker.cast_to.x, floor_checker.cast_to.y))

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever a t-rex's health is changed
func _on_t_rex_health_changed(amount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true

	if amount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)

	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# Triggered whenever a t-rex dies
func _on_t_rex_death() -> void:
	# Used to wait a given amount of time before deleting the entity
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

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 
