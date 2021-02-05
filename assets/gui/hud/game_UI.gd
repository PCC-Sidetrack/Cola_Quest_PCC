#-----------------------------------------------------------------------------#
# Class Name:   game_UI.gd
# Description:  Holds functions for controlling the various aspects of the UI
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends Control

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Signal that is activated when the player dies
signal player_killed (is_dead)
# Signal that is activated when a level is cleared
signal level_cleared ()
# Signal that is activated when the health of the player is changed
signal health_changed(current_health, previous_health)
# Signal that is activated when the player has low health
signal low_health    ()
# Signal that is activated when the game_UI is initiated
signal initialize    (max_health)
# Sgianl that is activated whenever the "retry" buttons are pressed
signal respawn_player()

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#	
# Emit signal on player killed 
func on_player_killed       (is_dead) -> void:
	emit_signal("player_killed", is_dead)

# Emit signal on level_cleared
func on_player_level_cleared() -> void:
	emit_signal("level_cleared")

# Emit signal when health changes
func on_health_changed      (current_health, previous_health) -> void:
	emit_signal("health_changed", current_health, previous_health)

# Emit signal when health is low
func on_health_low_health   () -> void:
	emit_signal("low_health")	

# Emit signal on initialization
# Only the max health is being passed, more parameters may be sent in the future 
func on_initialize          (max_health) -> void:
	emit_signal("initialize", max_health)

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#	
# Emit respawn signal when pause "retry" is pressed
func _on_pause_respawn_player() -> void:
	emit_signal("respawn_player")

# Emit respawn signal when failure "retry" is pressed
func _on_failure_respawn_player() -> void:
	emit_signal("respawn_player")
