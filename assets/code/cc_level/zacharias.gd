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
signal shake_screen(duration, frequency, amplitude)
signal boss_hit

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const TOTAL_STAGES: int = 3

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var gui               = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("player/game_UI")
onready var player_hurt       = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_node("player/sounds/SD19_player_hurt")
onready var audio
onready var fireball          = load("res://assets/sprite_scenes/cc_scenes/fireball.tscn")
onready var gust              = load("res://assets/sprite_scenes/cc_scenes/gust_projectile.tscn")
onready var quarter_note      = load("res://assets/sprite_scenes/cc_scenes/quarter_note.tscn")
onready var half_note         = load("res://assets/sprite_scenes/cc_scenes/half_note.tscn")
onready var beamed_note       = load("res://assets/sprite_scenes/cc_scenes/beamed_note.tscn")
onready var eighth_note       = load("res://assets/sprite_scenes/cc_scenes/eighth_note.tscn")
onready var animation_machine = $animation/animation_machine.get("parameters/playback")

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#
var current_stage: int  = 1
var damage:        int  = 1
var is_hurt:       bool = false

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _is_facing_player: bool   = true
var _last_state:       String = "idle1"
var _last_stage:       int    = 1

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
#-----------------------------------------------------------------------------#
var health: Dictionary = {
	1: {
		maximum = 6,
		current = 6,
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

var note_order: Dictionary = {
	1:
		1,
	2:
		2,
	3:
		3
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
func get_current_health() -> int:
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
	gui.on_boss_health_changed(get_current_health(), get_current_health() - 1)
	health[current_stage].current -= 1
	emit_signal("boss_hit")
	$hurt.play()

#func note_paths() -> void:
#	var chosen_path: int
#	var paths: Array = [1, 2, 3]
#	for order in note_order:
#		chosen_path = randi() % paths.size()
#		note_order[order] = paths[chosen_path]
#		paths.remove(chosen_path)

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
		if _last_stage == current_stage:
			get_node("sprites/stage" + String(current_stage) + "/" + _last_state).visible = false
			get_node("sprites/stage" + String(current_stage) + "/" + new_state).visible   = true
		else:
			get_node("sprites/stage" + String(current_stage - 1) + "/" + _last_state).visible = false
			get_node("sprites/stage" + String(current_stage) + "/" + new_state).visible       = true
			_last_stage = current_stage
		
		_last_state = new_state

# Shake the screen
func _shake_screen(duration: float, frequency: float, amplitude: float) -> void:
	emit_signal("shake_screen", duration, frequency, amplitude)

# Spawn a basketball
func _spawn_fire() -> void:
	var fire      = fireball.instance()
	var direction = Vector2(get_parent().scale.x, 0)
	var impulse   = direction * 150
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("projectiles").add_child(fire)
	
	fire.position = $fireball_spawn.global_position
	fire.fire_force(direction, impulse)

func _spawn_gust() -> void:
	var Gust = gust.instance()
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("projectiles").add_child(Gust)
	Gust.global_position = global_position
	Gust.scale = Vector2(3,3)
	Gust.speed = 16
	Gust.initialize()
	$gust_sound.play()

func _spawn_note() -> void:
	var choice: int = randi() % 4
	var spawned_note = quarter_note.instance()
	
	match choice:
		0:
			spawned_note = beamed_note.instance()
		1:
			spawned_note = eighth_note.instance()
		2:
			spawned_note = half_note.instance()
		3:
			spawned_note = quarter_note.instance()
	
	get_parent().get_parent().get_parent().get_parent().get_parent().get_node("projectiles").add_child(spawned_note)
	spawned_note.global_position = global_position
	spawned_note.scale = Vector2(3, 3)
	spawned_note.initialize()
	if randi() % 2 > 0:
		spawned_note.is_correct = true
		spawned_note.modulate   = Color(0, 255, 0)

	if not spawned_note.is_correct:
		spawned_note.modulate   = Color(255, 0, 0)
	

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hurt()


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		$landed_punch.play()
		body.take_damage(damage)
		if global_position.x > body.global_position.x:
			body.set_velocity(Vector2(-1000, -2000))
		else:
			body.set_velocity(Vector2(1000, -2000))
