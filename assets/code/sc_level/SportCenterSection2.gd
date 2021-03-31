#-----------------------------------------------------------------------------#
# File Name:   SportCenterSection2.gd
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
	get_tree().paused = true
	
	get_node("entities/player").load_from_transition()
	camera.zoom                  = Vector2(2,2)
	camera.limit_left            = 0
	camera.limit_top             = -1888
	camera.limit_bottom          = 160
	camera.limit_right           = 1024
	camera.current               = true
	camera.drag_margin_v_enabled = true
	camera.smoothing_enabled     = true
#
	portal.get_node("AnimationPlayer").play("transition_out")
