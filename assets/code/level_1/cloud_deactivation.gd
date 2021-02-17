#-----------------------------------------------------------------------------#
# Class Name:   cloud_deactivation.gd
# Description:  when triggered, deactivates the rooftop level foreground clouds
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 1, 2021
#-----------------------------------------------------------------------------#

extends Area2D

# When a body enters, if it is the player, the clouds get set to invisible.
func _on_decloud_trigger_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		get_node("/root/rooftop_level/parallaxing/clouds_below/ParallaxLayer").visible = false
