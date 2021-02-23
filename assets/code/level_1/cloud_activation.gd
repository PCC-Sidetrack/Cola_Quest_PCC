#-----------------------------------------------------------------------------#
# Class Name:   cloud_activation.gd
# Description:  when triggered, deactivates the rooftop level foreground clouds
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 1, 2021
#-----------------------------------------------------------------------------#

extends Area2D

# When a body enters, if it is the player, the clouds get set to invisible.
func _on_cloud_trigger_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
			get_node("/root/rooftop_level/parallaxing/clouds_below/ParallaxLayer").visible = true
			get_node("/root/rooftop_level/parallaxing/clouds_below/ParallaxLayer2").visible = true

