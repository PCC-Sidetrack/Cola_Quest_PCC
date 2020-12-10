extends CanvasLayer

func _on_Resume_pressed():
	$mouse_pressed.play()
	get_tree().paused = false

func _on_Retry_pressed():
	$mouse_pressed.play()
	get_tree().paused = false
#	return get_tree().change_scene("res://stages/christmas_stage/christmas_stage_dark.tscn")

func _on_Exit_pressed():
	$mouse_pressed.play()
	get_tree().quit()

func _on_Resume_mouse_entered():
	$mouse_hover.play()

func _on_Retry_mouse_entered():
	$mouse_hover.play()

func _on_Exit_mouse_entered():
	$mouse_hover.play()

func _on_Restart_pressed():
	pass # Replace with function body.

func _on_Restart_mouse_entered():
	pass # Replace with function body.
