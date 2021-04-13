#-----------------------------------------------------------------------------#
# File Name:    cc_1st_stage.gd                                               #
# Description:  Initializes the camera limits at the start of the stage       #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: March 26, 2021                                                #
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var camera = $player/Camera2D

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	camera.limit_left            = -768
	camera.limit_top             = -170
	camera.limit_right           = 256
	#camera.limit_right           = 3840
	camera.limit_bottom          = 430
	camera.zoom.x                = 2
	camera.zoom.y                = 2
	camera.current               = true
	camera.drag_margin_v_enabled = true
	camera.smoothing_enabled     = true
	camera.limit_smoothed        = true
	
	$cc_portal_door/AnimationPlayer.play("transition_out")