#-----------------------------------------------------------------------------#
# Class Name:   hud.gd
# Description:  Controls elements on the in-game UI
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: March 18, 2021
#-----------------------------------------------------------------------------#

extends Control

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Counts the amount of respawns
var _respawn_count: int = 0

# Counts the amount of cola collected 
var _cola_count:    int = 0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Hide respawn counter by default
func _ready() -> void:
	$ui_stat/stats/respawn_counter.visible       = false
	$ui_stat/stats/total_cola_collected.visible  = false

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
	_respawn_count += 1
	$ui_stat/stats/respawn_counter.visible       = false
	$ui_stat/stats/total_cola_collected.visible  = false

# COMMENT NEEDED
func _on_game_UI_level_cleared():
	yield(get_tree().create_timer(3.0), "timeout")
	$ui_stat/stats/total_cola_collected.visible  = true
	$ui_stat/stats/respawn_counter.visible       = true

# COMMENT NEEDED
func _on_game_UI_cola_collect(amount):
	_cola_count += amount
