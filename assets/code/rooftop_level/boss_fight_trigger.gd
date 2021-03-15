#-----------------------------------------------------------------------------#
# File Name:   	boss_fight_trigger.gd                                         #
# Description: 	Changes the viewing size of the camera for the level1 boss    #
#               fight.                                                        #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	February 1, 2021                                              #
#-----------------------------------------------------------------------------#

extends Area2D

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_boss_fight_trigger_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.zoom(1.25)
		
		# Enable the boss
		get_node("../../../enemies/zorro_boss").fight_enabled = true
		#Globals.player.get_node("game_UI").on_boss_healthbar_visible(true)
		
		# Initialze the boss healthbar
		#Globals.player.get_node("game_UI").on_initialize_boss(get_node("../../../player").max_health, "Dr. Geary (Zorro)")
	
		
		queue_free()
		
	
