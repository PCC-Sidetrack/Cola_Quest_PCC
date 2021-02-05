extends CanvasLayer

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Shakes the healthbar 
func _hud_shake() -> void:
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	$tween.interpolate_property(self, "offset", self.offset, Vector2(), .2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()

# Animate healthar change
func animate_value(start, end) -> void:
	$boss_healthbar/boss_health_normal.value = end
	$tween.interpolate_property($boss_healthbar/boss_health_loss, "value", start, end, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()
	


#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# COMMENT NEEDED
func _on_game_UI_initialize(_player_health, boss_health, boss_name) -> void:
	$boss_healthbar/hbox/boss_name.set_text(boss_name)
	$boss_healthbar/boss_health_normal.max_value = boss_health
	$boss_healthbar/boss_health_loss.max_value   = boss_health
	$boss_healthbar/boss_health_normal.value     = boss_health
	$boss_healthbar/boss_health_loss.value       = boss_health

# COMMENT NEEDED 
func _on_game_UI_boss_health_changed(current_health, previous_health):
	animate_value(previous_health, current_health)
	_hud_shake()


