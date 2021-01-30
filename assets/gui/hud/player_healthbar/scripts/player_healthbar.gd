#-----------------------------------------------------------------------------#
# Class Name:   player_healthbar.gd                                          
# Description:  GUI menu for player healthbar
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Determines whether the player healthbar can pulse
var can_pulse: bool = true

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
	$health_over.value = end
	$tween.interpolate_property($health_under, "value", start, end, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$tween.start()

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Repeat pulse animation after it finishes
func _on_pulse_tween_all_completed() -> void:
	if can_pulse == true:
		$low_health.play()
		$pulse.interpolate_property($health_over, "tint_progress", Color.black , Color.red, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$pulse.interpolate_property($low_health_border, "modulate", Color.white , Color.transparent, 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$pulse.start()

# On health change, animate healthbar
func _on_game_UI_health_changed(current_health, previous_health) -> void:
	animate_value(previous_health, current_health)
	_hud_shake()

# On low health, pulse healthbar
func _on_game_UI_low_health() -> void:
	_on_pulse_tween_all_completed()

# On player killed, disable healthbar pulsing and show cracked heart
func _on_game_UI_player_killed(is_dead) -> void:
	if is_dead == true:
		can_pulse              = false
		$heart.visible         = false
		$heart_cracked.visible = true
	else:
		can_pulse              = true
		$heart.visible         = true
		$heart_cracked.visible = false

# On level leared, disable healthbar pulsing
func _on_game_UI_level_cleared() -> void:
	can_pulse = false

# On UI intialize, set healthbar max health
func _on_game_UI_initialize(max_health) -> void:
	$health_over.max_value  = max_health
	$health_under.max_value = max_health
	$health_over.value      = max_health
	$health_under.value     = max_health
