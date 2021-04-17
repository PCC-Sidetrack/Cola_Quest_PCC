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

func shark_spawn() -> void:
	var shark = SHARK.instance()
	self.add_child(shark)
	shark.global_position = self.global_position

func _on_spawn_range_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		# Used to wait a given amount of time before spawn a shark
		var timer: Timer = Timer.new()
		timer.set_one_shot(true)
		add_child(timer)
		timer.start(2)
		yield(timer, "timeout")
		shark_spawn()
