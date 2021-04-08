#-----------------------------------------------------------------------------#
# File Name:   PlayerVariables.gd
# Description: Variables to be transferred between levels
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#

extends Node

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# How much health did the player have
var saved_health: int = 5
# How much cola had the player collected
var saved_cola:   int = 0
# How many times had the player died
var saved_deaths: int = 0

func new_level() -> void:
	if (saved_health != Globals.player.get_max_health()) and (saved_cola != 0) and (saved_deaths != 0):
		saved_health = Globals.player.get_max_health()
		saved_cola   = 0
		saved_deaths = 0

func restart_scene() -> void:
	saved_deaths += 1
	saved_health = Globals.player.get_max_health()

func reset_values() -> void:
	saved_cola   = 0
	saved_deaths = 0
	saved_health = Globals.player.get_max_health()
