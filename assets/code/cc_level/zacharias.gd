#-----------------------------------------------------------------------------#
# File Name:   zacharias.gd
# Description: General zacharias variables and functions
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 20, 2021
#-----------------------------------------------------------------------------#
extends StaticBody2D

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
signal started_jump
signal shake_screen(duration, frequency, amplitude)
signal boss_defeated
signal boss_hit

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const TOTAL_STAGES: int = 3

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var gui               = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("player/game_UI")
onready var audio
onready var fireball
onready var animation_machine = $animation/animation_machine.get("parameters/playback")

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#
var current_stage: int  = 1
var is_hurt:       bool = false

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _is_facing_player: bool   = true
var _last_state:       String = "idle1"

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
	pass

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _process(_delta: float) -> void:
	# Continuously check the current state to make sure that only the current animation is shown
	_manage_visibility(animation_machine.get_current_node())
	
	# If true, always face the player
	if _is_facing_player:
		_face_player()

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Flash the character with increasing frequency for the duration
func invulnerable_flicker(frequency: float) -> void:
	for period in frequency:
		get_parent().modulate.a = 0.5
		yield(get_tree(), "idle_frame")
		get_parent().modulate.a = 1.0
		yield(get_tree(), "idle_frame")

# Get the current health of the boss
func get_current_heatlh() -> int:
	var total: int = 0
	for stage in health:
		total += health[stage].current
	return total

# Get the total health of the boss
func get_total_health() -> int:
	var total: int = 0
	for stage in health:
		total += health[stage].maximum
	return total

func hurt() -> void:
	gui.on_boss_health_changed(get_current_heatlh(), get_current_heatlh() - 1)
	health[current_stage].current -= 1
	
	emit_signal("boss_hit")

func next_stage() -> void:
	current_stage += 1

func set_facing_direction(direction: int) -> void:
	get_parent().scale.x = direction * 3

func set_face_player(face_player: bool) -> void:
	_is_facing_player = face_player

func set_hurt(hurt: bool) -> void:
	is_hurt = hurt

func stage_completed() -> bool:
	return health[current_stage].current <= 0

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _face_player() -> void:
	if global_position.direction_to(Globals.player_position).x < 0:
		get_parent().scale.x = -3
	else:
		get_parent().scale.x = 3

func _is_dead() -> bool:
	return health[current_stage].current <= 0 and current_stage >= TOTAL_STAGES

# Change the currently showing animation to the new animation
func _manage_visibility(new_state) -> void:
	if _last_state != new_state and new_state != "":
		get_node("sprites/stage" + String(current_stage) + "/" + _last_state).visible = false
		get_node("sprites/stage" + String(current_stage) + "/" + new_state).visible   = true
		
		_last_state = new_state

# Shake the screen
func _shake_screen(duration: float, frequency: float, amplitude: float) -> void:
	emit_signal("shake_screen", duration, frequency, amplitude)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hurt()
