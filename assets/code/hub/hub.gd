#-----------------------------------------------------------------------------#
# Class Name:   hub.gd
# Description:  Script run during the hub scene
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 4/11/2021
#-----------------------------------------------------------------------------#

extends Node2D


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#
# Called when the node enters the scene tree for the first time.
func _ready():
	$scene_transition/AnimationPlayer.play("transition_out")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$pause.on_hub_level()
	
	Globals.stop_highscore_timer()
	Globals.reset_highscore_timer()
	
	# Start the day-night cycle
	$day_night_cycle/AnimationPlayer.play("day_night")
	

