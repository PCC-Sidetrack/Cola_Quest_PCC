#-----------------------------------------------------------------------------#
# File Name:   door.gd
# Description: Door switching to different scenes
# Author:      Eric Cherubin
# Company:     Sidetrack
# Date:        November 12, 2020
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# The scene that will be switched to
export (String, FILE) var target_scene


#-----------------------------------------------------------------------------#
#                           Private Functions                                 #
#-----------------------------------------------------------------------------#
# Compares to see if the overlapping body is other than parallaxing and error
# checks if there is a scene to switch to
func _input(event):
	if event.is_action_pressed("ui_up"):
		if (get_overlapping_bodies().size()) > 0:
			if get_tree().change_scene(target_scene) != OK:
				print("Error: No scene to change to!")