#-----------------------------------------------------------------------------#
# File Name:    drone_b_aiV2.gd                                               #
# Description:  Directs the animation and ai for the dronea sprite            #
# Author:       Jeff Newell                                                   #
# Company:      Sidetrack                                                     #
# Last Updated: December 2, 2020                                              #
#-----------------------------------------------------------------------------#

extends EntityV2

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:      bool  = true
# Movement speed
export var movement_speed:  float = 1.5625
# Seconds of movement before changing directions
export var turnaround_time: float = 2

export var health:       int   = 10
export var damage:       int   = 2
export var acceleration: float = 20.0

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	var instructions: Array = [
		duration (Vector2.UP, turnaround_time),
		end_point(global_position)
	]
	initialize_instructions(instructions, true)
	
	initialize_enemy(health, damage, movement_speed, acceleration)
	
	$AnimatedSprite.play("fly")


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		move()
