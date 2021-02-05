#-----------------------------------------------------------------------------#
# Class Name:   ui_statistics.gd
# Description:  Controls statistics displayed on UI
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: January 30, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Counts the amount of respawns
var _respawn_count: int = 0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Hide respawn counter by default
func _ready() -> void:
	$respawn_counter.visible = false

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
# Prints the fps onto a label
func _physics_process(_delta: float) -> void:
	$fps_counter.set_text("FPS: " + str(Engine.get_frames_per_second()))
	$respawn_counter.set_text("Respawn Counter: " + str(_respawn_count))

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On player killed, show respawn counter
func _on_game_UI_player_killed(is_dead) -> void:
	if is_dead == true:
		$respawn_counter.visible = true
	else:
		$respawn_counter.visible = false

# On player respawn, increment respawn counter
func _on_game_UI_respawn_player() -> void:
	_respawn_count += 1
