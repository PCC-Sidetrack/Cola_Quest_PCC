#-----------------------------------------------------------------------------#
# File Name:    cc_3rd_stage.gd                                               #
# Description:  Initializes the camera limits at the start of the stage       #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: April 1, 2021                                                 #
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var camera = $player/Camera2D
onready var portal = $cc_2nd_portal_door/AnimationPlayer
onready var gui    = $player/game_UI
onready var player = $player/AnimationPlayer

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	get_tree().paused = true
	
	camera.limit_left   = -544
	camera.limit_top    = -200
	camera.limit_right  = 5344
	camera.limit_bottom = 400
	camera.zoom.x = 1.8
	camera.zoom.y = 1.8
	camera.current               = true
	camera.drag_margin_v_enabled = true
	camera.smoothing_enabled     = true
	camera.limit_smoothed        = true
	
	portal.play("transition_out")
	get_node("player").load_from_transition()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		gui.on_player_level_cleared()
		player.play("idle")
