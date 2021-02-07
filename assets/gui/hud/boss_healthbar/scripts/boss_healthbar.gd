#-----------------------------------------------------------------------------#
# Class Name:   boss_healthbar.gd                                          
# Description:  GUI for boss healthbar
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: February 5, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	$boss_healthbar.visible = false

# Shakes the healthbar 
func _hud_shake() -> void:
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	yield(get_tree().create_timer(0.01), "timeout")
	set_offset(Vector2(rand_range(-2.0, 2.0) * 10, rand_range(-2.0, 2.0) * 5))
	$boss_healthbar/tween.interpolate_property(self, "offset", self.offset, Vector2(), .2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$boss_healthbar/tween.start()

# Animate healthar change
func animate_value(start, end) -> void:
	$boss_healthbar/boss_health_normal.value = end
	$boss_healthbar/tween.interpolate_property($boss_healthbar/boss_health_loss, "value", start, end, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$boss_healthbar/tween.start()

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On boss heatlh changed, animate value and shake 
func _on_game_UI_boss_health_changed(current_health, previous_health):
	animate_value(current_health, previous_health)
	_hud_shake()

# On boss initialization
func _on_game_UI_initialize_boss(max_health, boss_name) -> void:
	$boss_healthbar/hbox/boss_name.set_text(boss_name)
	$boss_healthbar/boss_health_normal.max_value = max_health
	$boss_healthbar/boss_health_loss.max_value   = max_health
	$boss_healthbar/boss_health_normal.value     = max_health
	$boss_healthbar/boss_health_loss.value       = max_health

# On boss heatlhbar visibility
func _on_game_UI_boss_healthbar_visible(visible):
	$boss_healthbar.visible = visible
