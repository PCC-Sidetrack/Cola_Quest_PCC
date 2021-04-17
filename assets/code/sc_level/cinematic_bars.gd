#-----------------------------------------------------------------------------#
# File Name:   cinematic_bars.gd
# Description: Controls the animation of the cinematic bars
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#

# Extends the Canvas Layer
extends CanvasLayer

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Plays the fade_in animation
func fade_in() -> void:
	$AnimationPlayer.play("fade_in")

# Plays the fade_out animation
func fade_out() -> void:
	$AnimationPlayer.play("fade_out")
