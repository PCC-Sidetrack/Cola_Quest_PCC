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
extends EntityV2

#-----------------------------------------------------------------------------#
<<<<<<< Updated upstream
=======
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Speed
export var movement_speed: float = 200.0

export var health:        int   = 10
export var damage:        int   = 5
export var acceleration:  float = 30.0
export var jump_velocity: float = 0.0
export var obeys_gravity: bool  = true

#-----------------------------------------------------------------------------#
>>>>>>> Stashed changes
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: float = _LEFT

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_obeys_gravity   (true)
	set_speed           (200.0, 700.0)
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
<<<<<<< Updated upstream
		_direction             = -_direction
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
=======
		_direction = -_direction
>>>>>>> Stashed changes
