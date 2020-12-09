#-----------------------------------------------------------------------------#
# File Name:   door.gd
# Description: Door switching to different scenes
# Author:      Eric Cherubin
# Company:     Sidetrack
# Date:        November 12, 2020
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
export (String, FILE) var target_scene


#-----------------------------------------------------------------------------#
#                            Physics/Process                                  #
#-----------------------------------------------------------------------------#
func _input(event):
	if event.is_action_pressed("ui_up"):
		if (get_overlapping_bodies().size()) > 0:
			if get_tree().change_scene(target_scene) != OK:
				print("Error: No scene to change to!")
