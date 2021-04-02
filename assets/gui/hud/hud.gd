#-----------------------------------------------------------------------------#
# Class Name:   hud.gd
# Description:  Controls elements on the in-game UI
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: April 1, 2021
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
# Green plus           (UI element)
onready var green_plus      = $ui_element/cola_healing/green_plus

# Green plus full      (UI element)
onready var green_plus_ss   = $ui_element/cola_healing/green_plus_ss

# Shows current fps    (UI element)
onready var fps_counter     = $ui_stat/stats/fps_counter

# Total cola collected (UI element)
onready var cola_collected  = $ui_element/cola_counter/cola_collected

# Respawn counter      (shown at end screen)
onready var respawn_count   = $ui_stat/stats/respawn_counter

# Total Cola collected (shown at end screen) 
onready var total_cola      = $ui_stat/stats/total_cola_collected

# Counts the amount of respawns
var _respawn_count:     int = 0

# Counts the amount of cola collected 
var _cola_count:        int = 0

# Number of cola required for healing to occur
var _cola_requirement:  int = 5

# Maximum player health
var _m_health:          int = 0

# Current player health
var _c_health:          int = 0

# Whether healing is enabled
var _healing_enabled:   bool = true

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Set ui elements to their default settings
func _ready() -> void:
	respawn_count.visible = false
	total_cola.visible    = false
	green_plus.max_value  = _cola_requirement
	green_plus.value      = 0
	green_plus_ss.visible = false

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
# Keep ui statistics updated
func _physics_process(_delta: float) -> void:
	cola_collected.set_text (" " + str(_cola_count))
	fps_counter.set_text    ("FPS: " + str(Engine.get_frames_per_second()))
	total_cola.set_text     ("Cola Collected : " + str(_cola_count))
	respawn_count.set_text  ("Respawn Counter: " + str(_respawn_count))

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On player killed, show respawn counter
func _on_game_UI_player_killed() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	respawn_count.visible = true

# On player respawn, increment respawn counter
func _on_game_UI_respawn_player() -> void:
	_healing_enabled      = true
	green_plus.value      =  0
	green_plus_ss.visible = false
	_respawn_count        += 1
	respawn_count.visible = false
	total_cola.visible    = false

# On game cleared, show level stats
func _on_game_UI_level_cleared() -> void:
	yield(get_tree().create_timer(3.0), "timeout")
	total_cola.visible    = true
	respawn_count.visible = true

# On collecting a cola(s)
func _on_game_UI_cola_collect(amount) -> void:
	_cola_count += amount

	# Animate cola icon
	$ui_element/cola_counter/cola_tween.interpolate_property($ui_element/cola_counter/cola_icon, "scale", Vector2(2,2), Vector2(1,1), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ui_element/cola_counter/cola_tween.start()
	
	if _healing_enabled:
		green_plus.value += amount
		if (green_plus.value == green_plus.max_value):
			green_plus_ss.visible = true
			green_plus.visible    = false
		if (green_plus.value == _cola_requirement) and (_c_health != _m_health):
			_cola_healing()

# On initialization
func _on_game_UI_initialize_player(max_health) -> void:
	_m_health = max_health
	_c_health = max_health

# On player health changing
func _on_game_UI_player_health_changed(_current_health, _previous_health) -> void:
	_c_health = _current_health
	
	if _healing_enabled == true:
		if (green_plus.value == _cola_requirement) and (_current_health < _previous_health):
			_cola_healing()

# On cola healing the player
func _cola_healing() -> void:
	emit_signal("cola_healing")
	green_plus.value      = 0
	green_plus_ss.visible = false
	green_plus.visible    = true

# On healing enabled
func _on_game_UI_healing_enabled(enabled) -> void:
	_healing_enabled = enabled
