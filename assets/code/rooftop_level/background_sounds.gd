#-----------------------------------------------------------------------------#
# Class Name:   background_sounds
# Description:  starts background sounds
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 2/26/2021
#-----------------------------------------------------------------------------#


extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Play all background sounds
	for child in get_children():
		if child is AudioStreamPlayer:
			child.play()

