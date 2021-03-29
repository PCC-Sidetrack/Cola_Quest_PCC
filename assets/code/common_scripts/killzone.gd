#-----------------------------------------------------------------------------#
# File Name:   	killzone.gd                                                   #
# Description: 	Attaches to an Area2D and causes any colliding entity to die  #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	December 4th, 2020                                            #
#-----------------------------------------------------------------------------#

extends Area2D

# Runs every physics engine update
func _physics_process(_delta) -> void:
	if Globals.player_position.y >= global_position.y and Globals.game_locked == false:
		Globals.player.take_damage(Globals.player.get_max_health())
