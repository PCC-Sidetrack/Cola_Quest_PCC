#-----------------------------------------------------------------------------#
# Class Name:   spikes
# Description:  Deals damage to the player if entered
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: April 10, 2021
#-----------------------------------------------------------------------------#

extends Node

#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Determines how much damage the damage_box deals
export var damage:           int   = 1
# Determines how much knockback is applied to the player
export var knockback:        float = 10.0
# Determines if the damage_box deals damage
export var deals_damage:     bool  = true
# Determines if the damage_box causes knockback
export var causes_knockback: bool  = true

func get_knockback_multiplier() -> float:
	return knockback

func _on_damage_box_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER) && body is Entity:
		if deals_damage:
			body.take_damage(damage)
		
		if causes_knockback: body.knockback  (self, Vector2.UP)
