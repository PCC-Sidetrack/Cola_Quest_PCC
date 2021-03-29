#-----------------------------------------------------------------------------#
# Class Name:   hud.gd
# Description:  Controls elements on the in-game UI
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: March 18, 2021
#-----------------------------------------------------------------------------#

extends Control

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emitted when cola healing occurs
signal cola_healing()

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Counts the amount of respawns
var _respawn_count:    int = 0

# Counts the amount of cola collected 
var _cola_count:       int = 0

# Number of cola required for healing to occur
var _cola_requirement: int = 5

# Maximum player health
var _m_health:         int = 0

# Current player health
var _c_health:         int = 0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Hide respawn counter by default
func _ready() -> void:
	$ui_stat/stats/respawn_counter.visible         = false
	$ui_stat/stats/total_cola_collected.visible    = false
	$ui_element/cola_healing/green_plus.max_value  = _cola_requirement
	$ui_element/cola_healing/green_plus.value      = 0
	$ui_element/cola_healing/green_plus_ss.visible = false

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
# Keep ui statistics updated
func _physics_process(_delta: float) -> void:
	$ui_element/cola_counter/cola_collected.set_text (" " + str(_cola_count))
	$ui_stat/stats/fps_counter.set_text              ("FPS: " + str(Engine.get_frames_per_second()))
	$ui_stat/stats/total_cola_collected.set_text     ("Cola Collected : " + str(_cola_count))
	$ui_stat/stats/respawn_counter.set_text          ("Respawn Counter: " + str(_respawn_count))

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On player killed, show respawn counter
func _on_game_UI_player_killed() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	$ui_stat/stats/respawn_counter.visible = true

# On player respawn, increment respawn counter
func _on_game_UI_respawn_player() -> void:
	$ui_element/cola_healing/green_plus.value    = 0
	_respawn_count += 1
	$ui_stat/stats/respawn_counter.visible       = false
	$ui_stat/stats/total_cola_collected.visible  = false

# On game cleared, show level stats
func _on_game_UI_level_cleared():
	yield(get_tree().create_timer(3.0), "timeout")
	$ui_stat/stats/total_cola_collected.visible  = true
	$ui_stat/stats/respawn_counter.visible       = true

# On collecting a cola(s)
func _on_game_UI_cola_collect(amount):
	_cola_count                               += amount
	$ui_element/cola_healing/green_plus.value += amount
	$ui_element/cola_counter/cola_tween.interpolate_property($ui_element/cola_counter/cola_icon, "scale", Vector2(2,2), Vector2(1,1), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ui_element/cola_counter/cola_tween.start()
	if ($ui_element/cola_healing/green_plus.value == $ui_element/cola_healing/green_plus.max_value):
		$ui_element/cola_healing/green_plus_ss.visible = true
		$ui_element/cola_healing/green_plus.visible    = false
	
	if ($ui_element/cola_healing/green_plus.value == _cola_requirement) and (_c_health != _m_health):
		_cola_healing()

# On initialization
func _on_game_UI_initialize_player(max_health) -> void:
	_m_health = max_health
	_c_health = max_health

# On player health changing
func _on_game_UI_player_health_changed(_current_health, _previous_health) -> void:
	_c_health = _current_health
	if ($ui_element/cola_healing/green_plus.value == _cola_requirement) and (_current_health < _previous_health):
		_cola_healing()

# On cola healing the player
func _cola_healing():
	emit_signal("cola_healing")
	$ui_element/cola_healing/green_plus.value      = 0
	$ui_element/cola_healing/green_plus_ss.visible = false
	$ui_element/cola_healing/green_plus.visible    = true
