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
func _on_Area2D_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		var camera = Globals.player.get_node("Camera2D")
		
		body.zoom(1.5)
		
		camera.limit_left  = -736
		camera.limit_right = 736
#		camera.drag_margin_h_enabled = true
#		camera.drag_margin_v_enabled = true
#		camera.drag_margin_left = 0.3
#		camera.drag_margin_right = 0.3
#		camera.drag_margin_top = 0.3
#		camera.drag_margin_bottom = 0.3
		
		queue_free()
