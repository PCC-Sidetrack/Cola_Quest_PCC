#-----------------------------------------------------------------------------#
# Class Name:   rooftop_level.gd
# Description:  Performs operations for the rooftop level
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 4/11/2021
#-----------------------------------------------------------------------------#

extends Node2D

func _ready():
	get_tree().paused = true
	Globals.game_locked = true
	$player/game_UI.on_game_ui_visible(false)
	if PlayerVariables.saved_deaths < 1:
		Story.show()
		Story.play("roof")
		yield(Story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false
	Globals.stop_highscore_timer()
	Globals.reset_highscore_timer()
	Globals.start_highscore_timer()

