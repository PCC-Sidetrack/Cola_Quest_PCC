#-----------------------------------------------------------------------------#
# File Name:   SC_kill_zone.gd
# Description: Kills the player if they go through this zone
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 1, 2021
#-----------------------------------------------------------------------------#

# Extends Area2D
extends Area2D

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _is_dead: bool = false

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _process(_delta: float) -> void:
	if _is_dead:
		Globals.player.take_damage(Globals.player.get_max_health())

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_SC_kill_zone_body_entered(body: Node) -> void:
	if body.has_method("prepare_transition"):
		PlayerVariables.restart_level()
		_is_dead = true
