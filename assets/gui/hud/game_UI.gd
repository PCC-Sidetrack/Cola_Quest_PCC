#-----------------------------------------------------------------------------#
# Class Name:   game_UI.gd
# Description:  Holds functions for controlling the various aspects of the UI
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: January 27, 2021
#-----------------------------------------------------------------------------#

extends Control

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Signal that is activated when the player dies
signal player_killed()
# Signal that is activated when a level is cleared
signal level_cleared()
# Signal that is activated when the health of the player is changed
signal health_changed(current_health, previous_health)
# Signal that is activated when the player has low health
signal low_health()

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#	
func on_player_killed() -> void:
	emit_signal("player_killed")

func on_player_level_cleared() -> void:
	emit_signal("level_cleared")

func on_health_changed(current_health, previous_health) -> void:
	emit_signal("health_changed", current_health, previous_health)

func on_health_low_health() -> void:
	emit_signal("low_health")	

