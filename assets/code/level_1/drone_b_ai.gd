#-----------------------------------------------------------------------------#
# File Name:   	drone_b_ai.gd                                                    #
# Description: 	Directs the animation and ai for the dronea sprite            #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:    	bool  = true
# Movement speed
export var movement_speed:	float = 30
# Seconds of movement before changing directions
export var turnaround_time: int   = 3

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# The vertical direction of current movement
var _vertical_direction: 	float = _UP
# The horizontal direction of the current movement
var _horizontal_direction:	float = _LEFT
# Number of seconds since last movement update
var _update_time:     		float = 0.0


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_obeys_gravity(false)
	set_type("hostile")
	set_speed(0.0, movement_speed)
	set_knockback_multiplier(0.25)
	_update_time += turnaround_time / 2
	$AnimatedSprite.play("fly")


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _process(delta: float) -> void:
	#print(get_knockback_multiplier())
	if ai_enabled:
		_update_time += delta
		# Calculate the movement of the drone
		if int(_update_time) >= turnaround_time:
			_vertical_direction = _DOWN if _vertical_direction == _UP else _UP
			_update_time = 0.0
		
		set_velocity((move_and_slide(Vector2(0.0, get_speed().y * _vertical_direction),
				get_floor_normal())))
