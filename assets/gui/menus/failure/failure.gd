extends CanvasLayer

onready var failure_text = $FailureScreen/FailureTextContainer/FailureText

func _on_FailureText_animation_finished():
	failure_text.animation = "text"

func _on_game_UI_player_killed():
	$FailureScreen.visible = true
	$failure.play()
	$FailureScreen/FailureBackgroundContainer/FailureBackground.play()
	failure_text.animation = "drop"
	failure_text.play()
	$buttons/ButtonScreen/Buttons/Retry.visible = true
	$buttons/ButtonScreen/Buttons/Exit.visible  = true
