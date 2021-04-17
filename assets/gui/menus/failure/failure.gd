#-----------------------------------------------------------------------------#
# Class Name:   failure.gd                                          
# Description:  GUI menu for failure screen
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

onready var retry   = $buttons/Control/VBoxContainer/CenterContainer2/Retry
onready var restart = $buttons/Control/VBoxContainer/CenterContainer3/Restart
onready var exit    = $buttons/Control/VBoxContainer/CenterContainer5/Exit
#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emit respawn signal when failure "retry" button is pressed
signal respawn_player()
var no_checkpoints = false

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Hide failure menu when "retry" button is pressed
func _input(_event) -> void:
	if retry.pressed == true:
		$FailureScreen.visible                      = false
		retry.visible = false
		exit.visible  = false
		$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible = false

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Repeat failure text animation "bounce" after it finishes
func _on_FailureText_animation_finished() -> void:
	$FailureScreen/FailureTextContainer/FailureText.animation = "text"

# Display failure menu on player death
func _on_game_UI_player_killed() -> void:
	yield(get_tree().create_timer(1.0), "timeout")

	get_tree().paused                                         = true
	$FailureScreen.visible                                    = true
	$failure.play()
	$FailureScreen/FailureBackgroundContainer/FailureBackground.play()
	$FailureScreen/FailureTextContainer/FailureText.animation = "drop"
	$FailureScreen/FailureTextContainer/FailureText.play()
	
	if no_checkpoints == false:
		retry.visible   = true
		exit.visible    = true
		$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible = true
	elif no_checkpoints == true:
		restart.visible = true
		exit.visible    = true
		$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible = true

# Emit respawn signal when "retry" button pressed
func _on_buttons_respawn_player() -> void:
	emit_signal("respawn_player")

# Disable retry button with no checkpoints enabled
func _on_game_UI_no_checkpoints():
	no_checkpoints = true

