#-----------------------------------------------------------------------------#
# File Name:   spawnpoint.gd
# Description: Script that sets the global spawnpoint
# Author:      Andrew Zedwick
# Company:     Sidetrack
# Date:        December 4, 2020
#-----------------------------------------------------------------------------#

extends Node2D

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Holds whether the spawnpoint has been activated already
var _activated: bool = false

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	$Area2D.set_collision_layer_bit(Globals.LAYER.SPAWNPOINT, true)
	$Area2D.set_collision_mask_bit(Globals.LAYER.PLAYER, true)
	add_to_group(Globals.GROUP.SPAWNPOINT)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Get whether the spawnpoint has already been activated
func get_activation_status() -> bool:
	return _activated

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_Area2D_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		if !_activated:
			body.set_spawn_point(global_position)
			_activated = true
