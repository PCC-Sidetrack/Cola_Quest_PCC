#-----------------------------------------------------------------------------#
# File Name:   SportCenterSection4.gd
# Description: Prepares the level
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var camera: Camera2D = $cameras/boss_arena
onready var portal: Node2D   = $world/portal_door

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	get_tree().paused = true
	
	get_node("entities/player").load_from_transition()
	
	# Set the camera correctly
	camera.zoom     = Vector2(2, 2)
	camera.position = Vector2(512, -47)
	camera.current  = true
	
	# Set the background to be black
	get_node("background/BackgroundScenery").modulate = Color(0,0,0)
	get_node("background/AnimatedSprite").modulate    = Color(0,0,0)
	get_node("world/ground").modulate                 = Color(0,0,0)
	
	# Move the boss to his correct position
	get_node("entities/boss/paths/intro/boss_position").unit_offset                    = 0
	get_node("entities/boss/paths/intro/boss_position/eagor/hurtbox/hurtbox").disabled = false
	get_node("entities/boss/paths").visible                                            = true
	
	# Initialize the boss healthbar
	get_node("entities/player/game_UI").on_initialize_boss(3, "Eagor")
	get_node("entities/player/game_UI").on_boss_healthbar_visible(true)
	
	Globals.player._has_spawn_points = false
	
	portal.get_node("AnimationPlayer").play("transition_out")
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	get_node("entities/boss/boss_movement/AnimationTree").get("parameters/playback").start("intro")

func lock_player() -> void:
	Globals.game_locked = true

func unlock_player() -> void:
	Globals.game_locked = false
