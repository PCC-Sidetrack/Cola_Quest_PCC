#-----------------------------------------------------------------------------#
# File Name:   running_eagor.gd
# Description: A basic enemy with basic AI
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 6, 2020
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                               Inheiritance                                  #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Speed
export var movement_speed:     Vector2 = Vector2(200, 700)
# Start facing right?
export var start_moving_right: bool    = false

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: float = _LEFT

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	# Flip the direction of the sprite if it's set to start right
	if start_moving_right:
		_direction = _RIGHT
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		
	set_obeys_gravity   (true)
	set_speed           (movement_speed.x, movement_speed.y)
	set_type            ("hostile")
	$AnimatedSprite.play("run")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	# Calculate and move the enemy
	set_velocity(move_and_slide(calculate_new_velocity(_direction), get_floor_normal()))
	
	# Change the direction the enemy is moving
	if is_on_wall():
		_direction             = -_direction
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
