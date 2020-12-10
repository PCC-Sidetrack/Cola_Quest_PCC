extends CanvasLayer

onready var confetti_left   = $CompletionScreen/BlackOverlay/confetti_left
onready var confetti_right  = $CompletionScreen/BlackOverlay/confetti_right
onready var completion_sign = $CompletionScreen/CompletionAnimationContainer/CompletionSign
onready var completion_text = $CompletionScreen/CompletionBackgroundContainer/CompletionText
	
func _on_CompletionSign_animation_finished():
	$cleared.play()
	completion_sign.visible   = false
	completion_text.visible   = true
	completion_text.animation = "glow"
	completion_text.playing   = true
	$buttons/ButtonScreen/Buttons/Retry.visible      = true
	$buttons/ButtonScreen/Buttons/Exit.visible       = true
	confetti_left.emitting    = true
	confetti_right.emitting   = true

func _on_CompletionText_animation_finished():
	completion_text.animation = "text"


func _on_game_UI_level_cleared():
	$completed.play()
	$CompletionScreen.visible = true
	completion_sign.play()
