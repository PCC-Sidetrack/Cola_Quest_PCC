#-----------------------------------------------------------------------------#
# File Name:   	camera_size_trigger.gd                                        #
# Description: 	Changes the viewing size of the camera for the level1 boss    #
#               fight.                                                        #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	December 8th, 2020                                            #
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_camera_size_trigger_body_entered(body):
		if body.is_in_group(Globals.GROUP.PLAYER):
				body.zoom(1.25)
				queue_free()
			
