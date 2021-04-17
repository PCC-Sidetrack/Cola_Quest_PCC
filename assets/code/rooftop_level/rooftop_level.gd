#-----------------------------------------------------------------------------#
# Class Name:   rooftop_level.gd
# Description:  Performs operations for the rooftop level
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 4/11/2021
#-----------------------------------------------------------------------------#

extends Node2D

func _ready():
	Globals.game_locked = true
	$player/game_UI.on_game_ui_visible(false)
	$story.show()
	$story.play("roof")
	yield($story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$story.hide()
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	get_tree().paused = true
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false

