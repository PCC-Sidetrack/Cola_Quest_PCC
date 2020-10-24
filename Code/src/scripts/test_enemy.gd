#-----------------------------------------------------------------------------#
# File Name:   test_enemy.gd
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
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: float = _RIGHT
# Time between jumps
var _time:      int   = 0

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_speed        (200.0, 700.0)
	set_obeys_gravity(true)
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	# Calculate and move the enemy
	set_velocity(move_and_slide(calculate_new_velocity(_direction), get_floor_normal()))
	
	# Change the direction the enemy is moving
	if is_on_wall():
		_direction = -_direction
	
	# Regulates when the enemy jumps
	if is_on_floor():
		_time += 1
		if _time >= 20:
			jump(1.0)
			_time = 0
