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
var hub_level      = false
var no_checkpoints = false

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Hide/Show pause menu and pause game if menu is shown
func _pause_unpause() -> void:
	var new_pause_state                           = not get_tree().paused
	get_tree().paused                             = new_pause_state
	$PausedScreen.visible                         = new_pause_state
	if hub_level == false and no_checkpoints == false:
		$buttons/Control/VBoxContainer/CenterContainer/Resume.visible  = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer3/Restart.visible = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer2/Retry.visible   = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer5/Exit.visible   = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible    = new_pause_state
	elif hub_level == true:
		$buttons/Control/VBoxContainer/CenterContainer/Resume.visible  = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer5/Exit.visible  = new_pause_state
	elif hub_level == false and no_checkpoints == true:
		$buttons/Control/VBoxContainer/CenterContainer/Resume.visible  = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer3/Restart.visible = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer5/Exit.visible    = new_pause_state
		$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible     = new_pause_state

# Pause/Unpause if pause button is pressed
func _input(event) -> void:
	if Globals.game_locked == false:
		if (event.is_action_pressed("ui_pause") and $buttons/exit_menu/exit_menu.visible == false)  or \
		$buttons/Control/VBoxContainer/CenterContainer/Resume.pressed  or \
		$buttons/Control/VBoxContainer/CenterContainer2/Retry.pressed   or \
		$buttons/Control/VBoxContainer/CenterContainer3/Restart.pressed:
			_pause_unpause()

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Emit respawn signal if pause menu "retry" button is pressed
func _on_buttons_respawn_player() -> void:
	#_can_pause = true
	emit_signal("respawn_player")

func on_hub_level():
	hub_level = true

func _on_game_UI_no_checkpoints():
	no_checkpoints = true

