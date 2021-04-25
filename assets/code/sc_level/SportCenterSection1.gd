#-----------------------------------------------------------------------------#
# File Name:   SportCenterSection1.gd
# Description: Prepares the level
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var camera: Camera2D = $entities/player.get_node("Camera2D")
onready var portal: Node2D   = $world/portal_door

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	Globals.game_locked = true
	get_tree().paused = true
	$entities/player/game_UI.on_game_ui_visible(false)
	if PlayerVariables.saved_deaths < 1:
		Story.show()
		Story.play("sc")
		yield(Story, "on_continue")
	$entities/player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	# Prepare the values for the scene
	$background/BA_arrow.visible = false
	camera.position              = Vector2(-512, 0)
	camera.anchor_mode           = 0
	camera.zoom                  = Vector2(2, 2)
	camera.limit_left            = 0
	camera.limit_top             = 0
	camera.limit_bottom          = 600
	camera.limit_right           = 3326
	camera.current               = true
	camera.drag_margin_h_enabled = true
	camera.smoothing_enabled     = true
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	PlayerVariables.new_level()
	Globals.player.has_spawn_points = false
	
	# Play the transition
	portal.get_node("AnimationPlayer").play("transition_out")
	yield(portal, "_on_transition_finished")
	Globals.start_highscore_timer()
