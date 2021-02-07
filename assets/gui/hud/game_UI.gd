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
signal player_killed         ()
# Signal that is activated when a level is cleared
signal level_cleared         ()
# Signal that is activated when the health of the player is changed
signal player_health_changed (current_health, previous_health)
# Signal that is activated when the health of the boss is changed 
signal boss_health_changed   (current_health, previous_health)
# Signal that is activated when the player has low health
signal low_health            ()
# Signal that is activated when the player is initiated
signal initialize_player     (max_health)
# Signal that is activated when the boss   is initiated
signal initialize_boss       (max_health, boss_name)
# Signal that is activated whenever the "retry" buttons are pressed
signal respawn_player        ()
# Signal that is activated when boss healthbar is shown
signal boss_healthbar_visible(visible)
# COMMENT NEEDED
signal flash_screen          (color)
# COMMENT NEEDED
signal cola_collect (amount)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#	
# Emit signal on player killed 
func on_player_killed        () -> void:
	emit_signal("player_killed")

# Emit signal on level_cleared
func on_player_level_cleared () -> void:
	emit_signal("level_cleared")

# Emit signal when player health changes
func on_player_health_changed(current_health, previous_health) -> void:
	emit_signal("player_health_changed", current_health, previous_health)

# Emit signal when boss health changes 
func on_boss_health_changed(current_health, previous_health) -> void:
	emit_signal("boss_health_changed", current_health, previous_health)

# Emit signal when health is low
func on_health_low_health    () -> void:
	emit_signal("low_health")	

# Emit signal on player initialization
# Only the max health is being passed, more parameters may be sent in the future 
func on_initialize_player    (max_health) -> void:
	emit_signal("initialize_player", max_health)

# Emit signal on boss initialization
func on_initialize_boss (max_health, boss_name) -> void:
	emit_signal("initialize_boss", max_health, boss_name)

# Emit signal when boss healthbar is shown
func on_boss_healthbar_visible(visible) -> void:
	emit_signal("boss_healthbar_visible", visible)

# Comment NEEDED
func on_flash_screen(color) -> void:
	emit_signal("flash_screen", color)

# COMMENT NEEDED
func on_cola_collect(amount) -> void:
	emit_signal("cola_collect", amount)
	
#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#	
# Emit respawn signal when pause "retry" is pressed
func _on_pause_respawn_player() -> void:
	emit_signal("respawn_player")

# Emit respawn signal when failure "retry" is pressed
func _on_failure_respawn_player() -> void:
	emit_signal("respawn_player")
