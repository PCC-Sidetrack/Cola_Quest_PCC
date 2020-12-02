#-----------------------------------------------------------------------------#
# File Name:   spawnpoint.gd
# Description: Script that sets the global spawnpoint
# Author:      Andrew Zedwick
# Company:     Sidetrack
# Date:        December 1, 2020
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
	$Area2D.set_collision_layer_bit(Globalsv2.LAYER.SPAWNPOINT, true)
	$Area2D.set_collision_mask_bit(Globalsv2.LAYER.PLAYER, true)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Set the spawnpoint as activated
func activate() -> void:
	_activated = true
	
# Set the spawnpoint as deactivated
func deactivate() -> void:
	_activated = true
	
# Get whether the spawnpoint has already been activated
func get_activation_status() -> bool:
	return _activated	
