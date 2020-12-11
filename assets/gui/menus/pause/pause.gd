extends CanvasLayer

var can_pause = true

func _pause_unpause():
	var new_pause_state                          = not get_tree().paused
	get_tree().paused                            = new_pause_state
	$PausedScreen.visible                        = new_pause_state
	$buttons/ButtonScreen/Buttons/Resume.visible = new_pause_state
#	$buttons/ButtonScreen/Buttons/Retry.visible  = new_pause_state
	$buttons/ButtonScreen/Buttons/Exit.visible   = new_pause_state
#
func _input(event):
	if can_pause == true:
		if event.is_action_pressed("pause") or  $buttons/ButtonScreen/Buttons/Resume.pressed == true:
			_pause_unpause()

func _on_game_UI_level_cleared():
	can_pause = false

func _on_game_UI_player_killed():
	can_pause = false
