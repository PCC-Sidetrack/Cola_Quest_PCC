#-----------------------------------------------------------------------------#
# File Name:   ZoomOut.gd
# Description: Script that zooms the camera out
# Author:      Luke Hathcock
# Company:     Sidetrack
# Date:        March 22, 2021
#-----------------------------------------------------------------------------#

extends Node2D

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
var zoomed_in = false
export var activate_boss = false

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	pass

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_Area2D_body_entered(_body):
	get_node("../../../player/game_UI").on_initialize_boss(10, "Projector")
	get_node("../../../player/game_UI").on_boss_healthbar_visible(true)
	if !zoomed_in:
		Globals.player.zoom(2)
		zoomed_in = true
		activate_boss = true
	else:
		Globals.player.zoom(.5)
		zoomed_in = false

