#-----------------------------------------------------------------------------#
# File Name:   	killzone.gd                                                   #
# Description: 	Attaches to an Area2D and causes any colliding entity to die  #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 31, 2021                                                #
#-----------------------------------------------------------------------------#

extends Area2D

func _physics_process(_delta) -> void:
	if Globals.player_position.y >= global_position.y and Globals.game_locked == false:
		get_owner().get_node("player/game_UI").on_healing_enabled(false)
		Globals.player.kill()

## Kill the player on entering area
#func _on_killzone_body_entered(body):
#	if body == Globals.player and Globals.game_locked == false:
#		Globals.player.set_invulnerability(0)
#		get_owner().get_node("player/game_UI").on_healing_enabled(false)
#		Globals.player.kill()
