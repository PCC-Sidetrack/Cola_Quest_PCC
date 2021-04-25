#-----------------------------------------------------------------------------#
# File Name:    portal.gd                                                     #
# Description:  Activates the flooding animation of the first floor of the    #
#               Crowne Centre.                                                #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: March 25, 2021                                                #
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
const SHARK = preload("res://assets/sprite_scenes/cc_scenes/shark.tscn")

export var spawn_cooldown:     float = 3

var spawn_update_time: float = 0.0
var can_spawn_shark: bool = false

func _process(delta: float) -> void:
	if can_spawn_shark and get_child_count() < 3:
		spawn_update_time += delta

		if spawn_update_time >= spawn_cooldown:
			shark_spawn()

func shark_spawn() -> void:
	var shark = SHARK.instance()
	self.add_child(shark)
	shark.global_position = self.global_position
	spawn_update_time = 0.0

func _on_spawn_range_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		can_spawn_shark = true


func _on_spawn_range_body_exited(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		can_spawn_shark = false
