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

func _on_Area2D_body_entered(body):
	if !zoomed_in:
		Globals.player.zoom(2)
		zoomed_in = true
	else:
		Globals.player.zoom(.33)
		zoomed_in = false

