#-----------------------------------------------------------------------------#
# File Name:   SportCenterSection3.gd
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
	camera.zoom                  = Vector2(1,1)
	camera.limit_left            = 0
	camera.limit_top             = 0
	camera.limit_bottom          = 600
	camera.limit_right           = 6592
	camera.current               = true
	camera.drag_margin_h_enabled = true
	camera.smoothing_enabled     = true
	
	portal.get_node("AnimationPlayer").play("transition_out")
