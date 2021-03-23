#-----------------------------------------------------------------------------#
# Class Name:   pause.gd                                          
# Description:  GUI menu for pause screen
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emit respawn signal when pause "retry" button is pressed
signal respawn_player()

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Hide/Show pause menu and pause game if menu is shown
func _pause_unpause() -> void:
	var new_pause_state                           = not get_tree().paused
	get_tree().paused                             = new_pause_state
	$PausedScreen.visible                         = new_pause_state
	$buttons/ButtonScreen/Buttons/Resume.visible  = new_pause_state
	$buttons/ButtonScreen/Buttons/Restart.visible = new_pause_state
	$buttons/ButtonScreen/Buttons/Retry.visible   = new_pause_state
	$buttons/ButtonScreen/Buttons/Exit.visible    = new_pause_state

# Pause/Unpause if pause button is pressed
func _input(event) -> void:
	if Globals.game_locked == false:
		if event.is_action_pressed("ui_pause")        or \
		$buttons/ButtonScreen/Buttons/Resume.pressed  or \
		$buttons/ButtonScreen/Buttons/Retry.pressed   or \
		$buttons/ButtonScreen/Buttons/Restart.pressed or \
		$buttons/ButtonScreen/Buttons/Exit.pressed:
			_pause_unpause()

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Emit respawn signal if pause menu "retry" button is pressed
func _on_buttons_respawn_player() -> void:
	#_can_pause = true
	emit_signal("respawn_player")
