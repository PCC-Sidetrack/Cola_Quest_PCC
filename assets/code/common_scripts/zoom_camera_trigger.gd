#-----------------------------------------------------------------------------#
# File Name:   	zoom_camera_trigger.gd                                         #
# Description: 	Changes the viewing size of the camera for the level1 boss    #
#               fight.                                                        #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	February 10, 2021                                              #
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_zoom_camera_trigger_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.zoom(1.5)
		queue_free()
