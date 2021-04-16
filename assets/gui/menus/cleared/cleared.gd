#-----------------------------------------------------------------------------#
# Class Name:   cleared.gd                                          
# Description:  GUI menu for level cleared
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Confetti on left side of screen
onready var _confetti_left   = $CompletionScreen/BlackOverlay/confetti_left
# Confetti on right side of screen
onready var _confetti_right  = $CompletionScreen/BlackOverlay/confetti_right
# Completion animation
onready var _completion_sign = $CompletionScreen/CompletionAnimationContainer/CompletionSign
# Completion text on "level cleared" menu
onready var _completion_text = $CompletionScreen/CompletionBackgroundContainer/CompletionText

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Show level cleared menu after the text animation finishes
func _on_CompletionSign_animation_finished() -> void:
	$cleared.play()
	_completion_sign.visible                      = false
	_completion_text.visible                      = true
	_completion_text.animation                    = "glow"
	_completion_text.playing                      = true
	$buttons/Control/VBoxContainer/CenterContainer3/Restart.visible = true
	$buttons/Control/VBoxContainer/CenterContainer4/Hub.visible = true
	$buttons/Control/VBoxContainer/CenterContainer5/Exit.visible    = true
	_confetti_left.emitting                       = true
	_confetti_right.emitting                      = true

# Repeat text animation each time it finishes
func _on_CompletionText_animation_finished() -> void:
	_completion_text.animation = "text"

# On level cleared, show level cleared menu
func _on_game_UI_level_cleared() -> void:
	Globals.player.set_invulnerability(99999)
	Globals.game_locked       = true
	$completed.play()
	$CompletionScreen.visible = true
	_completion_sign.play()
