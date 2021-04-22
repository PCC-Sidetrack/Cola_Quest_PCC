#-----------------------------------------------------------------------------#
# File Name:   	zoom_camera_trigger.gd                                         #
# Description: 	Changes the viewing size of the camera for the level1 boss    #
#               fight.                                                        #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	February 10, 2021                                              #
#-----------------------------------------------------------------------------#

extends Area2D

onready var boss = get_parent().get_parent().get_node("enemies/boss")

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_Area2D_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		$CollisionShape2D.set_deferred("disabled", true)
		
		var camera = Globals.player.get_node("Camera2D")
		
		body.zoom(1.8)
		
		camera.limit_left  = -736
		camera.limit_right = 736
		
		yield(get_tree().create_timer(1.5), "timeout")
		boss.start_fight()
		
		queue_free()
