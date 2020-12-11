extends CanvasLayer

var can_pulse = true

func _hud_shake():
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	$tween.interpolate_property(self, "offset", self.offset, Vector2(), .2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()

func animate_value(start, end):
	$health_over.value = end
	$tween.interpolate_property($health_under, "value", start, end, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()

func _on_pulse_tween_all_completed():
	if can_pulse == true:
		$low_health.play()
		$pulse.interpolate_property($health_over, "tint_progress", Color.black , Color.red, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$pulse.interpolate_property($low_health_border, "modulate", Color.white , Color.transparent, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$pulse.start()

func _on_game_UI_health_changed(current_health, previous_health):
	animate_value(previous_health, current_health)
	_hud_shake()

func _on_game_UI_low_health():
	_on_pulse_tween_all_completed()

func _on_game_UI_player_killed():
	can_pulse = false
	$heart.visible = false
	$heart_cracked.visible = true

func _on_game_UI_level_cleared():
	can_pulse = false
