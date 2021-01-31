#-----------------------------------------------------------------------------#
# Class Name:   failure.gd                                          
# Description:  GUI menu for failure screen
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emit respawn signal when failure "retry" button is pressed
signal respawn_player()

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Hide failure menu when "retry" button is pressed
func _input(_event) -> void:
	if $buttons/ButtonScreen/Buttons/Retry.pressed == true:
		$FailureScreen.visible                      = false
		$buttons/ButtonScreen/Buttons/Retry.visible = false
		$buttons/ButtonScreen/Buttons/Exit.visible  = false

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Repeat failure text animation "bounce" after it finishes
func _on_FailureText_animation_finished() -> void:
	$FailureScreen/FailureTextContainer/FailureText.animation = "text"

# Display failure menu on player death
func _on_game_UI_player_killed(is_dead) -> void:
	if is_dead                == true:
		get_tree().paused      = true
		$FailureScreen.visible = true
		$failure.play()
		$FailureScreen/FailureBackgroundContainer/FailureBackground.play()
		$FailureScreen/FailureTextContainer/FailureText.animation = "drop"
		$FailureScreen/FailureTextContainer/FailureText.play()
		$buttons/ButtonScreen/Buttons/Retry.visible               = true
		$buttons/ButtonScreen/Buttons/Exit.visible                = true

# Emit respawn signal when "retry" button pressed
func _on_buttons_respawn_player() -> void:
	emit_signal("respawn_player")
