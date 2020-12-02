#-----------------------------------------------------------------------------#
# File Name:   	bird.gd                                                       #
# Description: 	Directs the animation and ai for the bird sprite              #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 12th, 2020                                           #
#-----------------------------------------------------------------------------#

extends EntityV2

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:         bool  = true
# Movement speed
export var movement_speed:     float = 1.875
# Seconds of movement before changing directions
export var turnaround_time:    float = 3.0
# Start facing right?
#export var start_moving_right: bool  = true
export var health: int = 10
export var damage: int = 5
export var accelertion: float = 20.0

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# The horizontal direction of the current movement
#var _direction:   float = _RIGHT
# Number of seconds since last movement update
#var _update_time: float = 0.0

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
#func _ready() -> void:
#	set_obeys_gravity(false)
#	set_type("hostile")
#	set_speed(movement_speed, 0.0)
#	_update_time += turnaround_time / 2
#	if not start_moving_right:
#		_direction = _LEFT
#		$AnimatedSprite.flip_h = true
#	$AnimatedSprite.play("fly")
func _ready() -> void:
	var instructions = [
		duration (Vector2.RIGHT, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions    (instructions, true)
	initialize_enemy           (health, damage, movement_speed, accelertion)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("fly")


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
#func _physics_process(delta: float) -> void:
#	if ai_enabled:
#		_update_time += delta
#
#		# Calculate the movement of the drone
#		if int(_update_time) >= turnaround_time:
#			if _direction == _RIGHT:
#				_direction = _LEFT
#				$AnimatedSprite.flip_h = true
#			else:
#				_direction = _RIGHT
#				$AnimatedSprite.flip_h = false
#
#			_update_time = 0.0
#
#		set_velocity((move_and_slide(Vector2(get_speed().x * _direction, 0.0),
#				get_floor_normal())))
func _physics_process(delta: float) -> void:
	if ai_enabled:
		move()
