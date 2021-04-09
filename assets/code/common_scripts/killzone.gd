#-----------------------------------------------------------------------------#
# File Name:   	killzone.gd                                                   #
# Description: 	Attaches to an Area2D and causes any colliding entity to die  #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 31, 2021                                                #
#-----------------------------------------------------------------------------#

extends Area2D

# Runs every physics engine update
#func _physics_process(_delta) -> void:
#	if Globals.player_position.y >= global_position.y and Globals.game_locked == false:
# *** NOTICE ***: Unstable code above, commented out

# Kill the player on entering area
func _on_killzone_body_entered(body):
	if body == Globals.player and Globals.game_locked == false:
		Globals.player.set_invulnerability(0)
		get_owner().get_node("player/game_UI").on_healing_enabled(false)
		Globals.player.kill()

func _on_SC_killzone_body_entered(body: Node) -> void:
	if body == Globals.player and Globals.game_locked == false:
		Globals.player.set_invulnerability(0)
		get_owner().get_node("entities/player/game_UI").on_healing_enabled(false)
		Globals.player.kill()
