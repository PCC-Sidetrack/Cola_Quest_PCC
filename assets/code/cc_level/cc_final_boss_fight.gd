#-----------------------------------------------------------------------------#
# File Name:    cc_3rd_stage.gd                                               #
# Description:  Initializes the camera limits at the start of the stage       #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: April 1, 2021                                                 #
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var camera = $player/Camera2D
onready var portal = $cc_2nd_portal_door/AnimationPlayer

const SHAKE_SCRIPT = preload("res://assets/code/sc_level/boss_arena_camera.gd")

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	get_tree().paused = true
	
	
	$player/game_UI.on_initialize_boss($enemies/boss/paths/balcony_stage/boss_position/zacharias.get_total_health(), "Dr. Zacharias")
	$player/game_UI.on_boss_healthbar_visible(true)
	
	camera.set_script(SHAKE_SCRIPT)
	$enemies/boss/paths/balcony_stage/boss_position/zacharias.connect("shake_screen", $player/Camera2D, "shake")
	
	$player.has_spawn_points = false
	
	portal.play("transition_out")
	get_node("player").load_from_transition()
