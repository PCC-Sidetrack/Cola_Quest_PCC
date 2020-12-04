#-----------------------------------------------------------------------------#
# File Name:   	killzone.gd                                                   #
# Description: 	Attaches to an Area2D and causes any colliding entity to die  #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	December 4th, 2020                                            #
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_killzone_body_entered(body):
	if body.has_method("kill"):
		body.kill()
