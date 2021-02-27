#-----------------------------------------------------------------------------#
# Class Name:   zorro_sword.gd
# Description:  Controls the sword Zorro weilds.
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 16, 2021
#-----------------------------------------------------------------------------#

extends Area2D

# Stores the knockback value applied to the player if they get hit by the sword
var _knockback_multiplier: float = 1.0

# Returns the knockback multiplier of the sword
# Used in the knockback function called in _on_sword_body_entered to tell the player how
# far to be knocked back.
func get_knockback_multiplier() -> float:
	return _knockback_multiplier

# If the player runs into the sword, then it damages him/her
func _on_sword_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER) && body is Entity:
		body.take_damage(1)
		body.knockback(self)
