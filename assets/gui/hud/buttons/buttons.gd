#-----------------------------------------------------------------------------#
# Class Name:   buttons.gd
# Description:  GUI menu buttons that are used on every menu
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emits respawn signal when "retry" buttons have been pressed
signal respawn_player()

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
	$mouse_pressed.play()
	get_tree().quit()

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
	Globals.game_locked = false
	return get_tree().reload_current_scene()

# On restart button mouse hover
func _on_Restart_mouse_entered() -> void:
	pass
