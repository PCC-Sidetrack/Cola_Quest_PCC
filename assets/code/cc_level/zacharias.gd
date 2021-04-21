#-----------------------------------------------------------------------------#
# File Name:   zacharias.gd
# Description: The AI for the zacharias boss fight
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 20, 2021
#-----------------------------------------------------------------------------#
extends StaticBody2D

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var total_stages: int = 3

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#
var current_stage: int  = 1
var is_hurt:       bool = false

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _is_facing_player: bool   = true
var _last_state:       String = "idle"

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
#-----------------------------------------------------------------------------#
var health: Dictionary = {
	1: {
		maximum = 3,
		current = 3,
	},
	2: {
		maximum = 3,
		current = 3,
	},
	3: {
		maximum = 3,
		current = 3
	}
}

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	pass # Replace with function body.

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Get the current health of the boss
func get_current_heatlh() -> int:
	var total: int = 0
	for stage in health:
		total += health[total].current
	return total

# Get the total health of the boss
func get_total_health() -> int:
	var total: int = 0
	for stage in health:
		total += health[stage].maximum
	return total

func hurt() -> void:
	health[current_stage].current -= 1

func set_hurt(hurt: bool) -> void:
	is_hurt = hurt

func stage_completed() -> bool:
	return health[current_stage].current <= 0

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _face_player() -> void:
	if global_position.direction_to(Globals.player_position).x >= 0:
		get_parent().scale.x = -3
	else:
		get_parent().scale.x = 3

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hurt()
