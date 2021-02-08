#-----------------------------------------------------------------------------#
# Class Name:   zorro_sword.gd
# Description:  Controls the sword Zorro weilds.
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 7, 2021
#-----------------------------------------------------------------------------#

extends Area2D

# If the player runs into the sword, then it damages him/her
func _on_sword_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER) && body is Entity:
		body.take_damage(1)
