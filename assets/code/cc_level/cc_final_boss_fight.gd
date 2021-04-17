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

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	get_tree().paused = true
	portal.play("transition_out")
	get_node("player").load_from_transition()
