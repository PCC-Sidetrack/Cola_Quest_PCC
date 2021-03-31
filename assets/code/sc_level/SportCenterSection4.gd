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
	camera.zoom                  = Vector2(2, 2)
	camera.position              = Vector2(512, -47)
	camera.current               = true
	
	get_node("background/BackgroundScenery").modulate = Color(0,0,0)
	get_node("background/AnimatedSprite").modulate    = Color(0,0,0)
	get_node("world/ground").modulate                 = Color(0,0,0)
	
	get_node("entities/boss/paths/intro/boss_position").unit_offset = 0
	get_node("entities/boss/paths").visible = true
	
	portal.get_node("AnimationPlayer").play("transition_out")
	#get_tree().get_node("entities/player").paused = true
	
	get_node("entities/boss/boss_movement/AnimationTree").get("parameters/playback").start("intro")
