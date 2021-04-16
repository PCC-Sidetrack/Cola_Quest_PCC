#-----------------------------------------------------------------------------#
# Class Name:   buttons.gd
# Description:  GUI menu buttons that are used on every menu
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: April 1, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emits respawn signal when "retry" buttons have been pressed
signal respawn_player()

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Current selected button
var current_selection:int = 0

# Resume button
var resume_button:    int = 0

# Retry button
var retry_button:     int = 1

# Restart button
var restart_button:   int = 2

# Exit button
var exit_button:      int = 3

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On resume button pressed
func _on_Resume_pressed() -> void:
	$mouse_pressed.play()
	get_tree().paused = false

# On retry button pressed
func _on_Retry_pressed() -> void:
	$mouse_pressed.play()
	get_tree().paused = false
	emit_signal("respawn_player")

# On exit button pressed
func _on_Exit_pressed() -> void:
	$exit_menu/exit_menu.visible = true
	$mouse_pressed.play()


# On resume button mouse hover
func _on_Resume_mouse_entered() -> void:
	$mouse_hover.play()

# On retry button mouse hover
func _on_Retry_mouse_entered() -> void:
	$mouse_hover.play()

# On exit button mouse hover
func _on_Exit_mouse_entered() -> void:
	$mouse_hover.play()

# On restart button pressed
func _on_Restart_pressed():
	get_tree().paused = false
	Globals.game_locked = false
	SceneFade.change_scene(get_tree().current_scene.filename, 'fade')
	get_tree().current_scene.queue_free()

# On restart button mouse hover
func _on_Restart_mouse_entered() -> void:
	pass

### Control buttons with keyboard
#func _input(event) -> void:
#	if Globals.game_locked == true:
#		if event.is_action_pressed("ui_up") and current_selection > resume_button:
#			current_selection -= 1 
#			$mouse_hover.play()
#		elif event.is_action_pressed("ui_down") and current_selection < exit_button:
#			current_selection += 1 
#			$mouse_hover.play()
#		elif event.is_action_pressed("ui_up") and current_selection == resume_button:
#			current_selection = exit_button
#			$mouse_hover.play()
#		elif event.is_action_pressed("ui_down") and current_selection == exit_button:
#			current_selection = resume_button
#			$mouse_hover.play()
#		elif event.is_action_pressed("ui_accept"):
#			_handle_selection(current_selection)
#
## Handle the current selection
#func _handle_selection(_current_selection) -> void:
#	if Globals.game_locked == false:
#		match _current_selection:
#			resume_button:
#				_on_Resume_pressed()
#			retry_button:
#				_on_Retry_pressed()
#			restart_button:
#				_on_Restart_pressed()
#			exit_button:
#				_on_Exit_pressed()


func _on_back_pressed():
	$exit_menu/exit_menu.visible = false

func _on_Hub_pressed():
	get_tree().paused = false
	SceneFade.change_scene("res://assets/levels/hub.tscn", 'fade')
	get_tree().current_scene.queue_free()

func _on_main_menu_pressed():
	get_tree().paused = false
	SceneFade.change_scene("res://assets/gui/menus/main_menu/main_menu.tscn", 'fade')
	get_tree().current_scene.queue_free()

func _on_desktop_pressed():
	Globals.game_locked = true
	get_tree().quit()
