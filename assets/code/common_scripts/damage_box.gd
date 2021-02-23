#-----------------------------------------------------------------------------#
# Class Name:   damage_box
# Description:  Deals damage to the player if entered, then teleports the player
#               to their last spawn point.
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 2/22/2021
#-----------------------------------------------------------------------------#

extends Node

#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Determines how much damage the damage_box deals
export var damage:           int   = 1
# Determines how much knockback is applied to the player
export var knockback:        float = 1.5
# Determines if the damage_box deals damage
export var deals_damage:     bool  = true
# Determines if the damage_box causes knockback
export var causes_knockback: bool  = true
# Determines if the player is sent to the previous spawn point
export var tp_to_spawn:      bool  = true

# Returns the knockback multiplier of the sword
# Used in the knockback function called in _on_sword_body_entered to tell the player how
# far to be knocked back.
func get_knockback_multiplier() -> float:
	return knockback

# When the collision box is entered, check if the player entered it before dealing
# damage.
func _on_damage_box_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER) && body is Entity:
		if deals_damage:     body.take_damage(damage)
		if causes_knockback: body.knockback  (self, Vector2.UP)
		if tp_to_spawn:
			# Wait to respawn for a moment
			Globals.game_locked = true
			yield(get_tree().create_timer(0.3), "timeout")
			body.global_position = body.get_spawn_point()
			yield(get_tree().create_timer(0.3), "timeout")
			Globals.game_locked = false
		
		body.set_invulnerability(body.invlunerability_time)
