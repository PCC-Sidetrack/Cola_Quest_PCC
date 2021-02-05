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
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Determines whether the player can display the pause menu
var _can_pause: bool = true

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Hide/Show pause menu and pause game if menu is shown
func _pause_unpause() -> void:
	var new_pause_state                          = not get_tree().paused
	get_tree().paused                            = new_pause_state
	$PausedScreen.visible                        = new_pause_state
	$buttons/ButtonScreen/Buttons/Resume.visible = new_pause_state
	$buttons/ButtonScreen/Buttons/Retry.visible  = new_pause_state
	$buttons/ButtonScreen/Buttons/Exit.visible   = new_pause_state

# Pause/Unpause if pause button is pressed
func _input(event) -> void:
	if _can_pause == true:
		if event.is_action_pressed("ui_pause")        or \
		$buttons/ButtonScreen/Buttons/Resume.pressed  or \
		$buttons/ButtonScreen/Buttons/Retry.pressed:
			_pause_unpause()

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Prevent pause menu from being shown if level is cleared
func _on_game_UI_level_cleared() -> void:
	_can_pause = false

# Prevent pause menu from being shown if player is dead
func _on_game_UI_player_killed(is_dead) -> void:
	if is_dead == true:
		_can_pause = false
	else:
		_can_pause = true

# Emit respawn signal if pause menu "retry" button is pressed
func _on_buttons_respawn_player() -> void:
	emit_signal("respawn_player")
