#-----------------------------------------------------------------------------#
# File Name:   eagor.gd
# Description: The AI for the eagor boss fight
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 25, 2021
#-----------------------------------------------------------------------------#
extends StaticBody2D

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
signal eagor_hit
signal _on_boss_defeated
signal shake_screen(duration, frequency, amplitude)

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const RANGE_MAX:       int        = 99
const RANGE_MIN:       int        = 0
const TOTAL_STAGES:    int        = 3
const STAGE_VARIABLES: Dictionary = {
	1: {
		ball_attacks = 1,
		delay        = 2.0,
		idle_chance  = 45,
		jump_chance  = 20,
		speed        = 1.0,
		throw_chance = 35,
		waves        = 1,
	},
	2: {
		ball_attacks = 1,
		delay        = 1.7,
		idle_chance  = 35,
		jump_chance  = 20,
		speed        = 1.5,
		throw_chance = 45,
		waves        = 1,
	},
	3: {
		ball_attacks = 2,
		delay        = 1.0,
		idle_chance  = 25,
		jump_chance  = 30,
		speed        = 2.0,
		throw_chance = 45,
		waves        = 2,
	},
}

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var ball_speed: int = 100
export var damage:     int = 1
export(int, 1, 5)      var full_health = 3
export var speed:      int = 16

export var knockback:  float = 3.0
export var sound:      AudioStream

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#
var current_stage: int  = 1
var current_wave:  int  = 1
var is_hurt:       bool = false
var player_close:  bool = false

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _current_health:   int     = full_health
var _is_facing_player: bool    = true
var _last_state:       String  = "idle"

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var audio             = $AudioStreamPlayer2D
onready var basketball        = preload("res://assets/sprite_scenes/sc_level/basketball.tscn")
onready var animation_machine = $AnimationTree.get("parameters/playback")
onready var gui               = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("player/game_UI")

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	$AnimationTree["parameters/swipe/TimeScale/scale"] = STAGE_VARIABLES[current_stage].speed
	$AnimationTree["parameters/throw/TimeScale/scale"] = STAGE_VARIABLES[current_stage].speed
	
	audio.stream      = sound
	audio.volume_db   = -10
	audio.pitch_scale = 0.8

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
#                             Thread Functions                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Flash the character with increasing frequency for the duration
func invulnerable_flicker(frequency: float) -> void:
	for period in frequency:
		$sprites/hurt.self_modulate.a = 0.5
		yield(get_tree(), "idle_frame")
		$sprites/hurt.self_modulate.a = 1.0
		yield(get_tree(), "idle_frame")

# This function is only here because of how melee combat was implemented
# In this entity, it is completely useless
func custom_knockback(_useless_parameter1, _useless_parameter2) -> void:
	pass

# Get the speed of the basketball
func get_speed() -> int:
	return speed

# Get the knockback multiplier of the basketball
func get_knockback_multiplier() -> float:
	return knockback

# Get the current health of eagor
func get_current_health() -> int:
	return _current_health

# Called when eagor gets hurt
# Useable only with the hitbox/hurtbox system
func hurt() -> void:
	gui.on_boss_health_changed(_current_health, _current_health - 1)
	_current_health -= 1
	
	$sword_hit.play()
	if current_stage >= TOTAL_STAGES and _current_health == 0:
		pass
	else:
		$hurt.play()
	
	emit_signal("eagor_hit")

# Move eagor to the next stage in the fight
func next_stage() -> void:
	if current_stage < TOTAL_STAGES:
		current_stage  += 1
		current_wave    = 1
		gui.on_boss_health_changed(_current_health, full_health)
		
		_current_health = full_health
		
		$AnimationTree["parameters/swipe/TimeScale/scale"] = STAGE_VARIABLES[current_stage].speed
		$AnimationTree["parameters/throw/TimeScale/scale"] = STAGE_VARIABLES[current_stage].speed
		#$AnimationTree["parameters/jump/TimeScale/scale"]  = STAGE_VARIABLES[current_stage].speed

# Start the animation machine
func start_fight() -> void:
	$sprites/roar.visible = false
	animation_machine.start("idle")
	pass

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Set whether the particles are emitting
func _emit_particles(is_emitting: bool) -> void:
	$particles/bolts.emitting = is_emitting
	$particles/nuts.emitting  = is_emitting

# Did eagor just get hurt
func _set_hurt(hurt: bool) -> void:
	is_hurt = hurt
	
# Make eagor face the player
func _face_player() -> void:
	if global_position.direction_to(Globals.player_position).x >= 0:
		get_parent().scale.x = -2
	else:
		get_parent().scale.x = 2

# Is eagor out of health and is this the final stage
func is_dead() -> bool:
	return (_current_health <= 0 and current_stage >= 3)

# Change the currently showing animation to the new animation
func _manage_visibility(new_state) -> void:
	if _last_state != new_state:
		get_node("sprites/" + _last_state).visible = false
		get_node("sprites/" + new_state).visible   = true
		
		_last_state = new_state

# Specifically call an animation and makes sure that it is the only animation playing
func _play_animation(anim_name: String) -> void:
	for sprite in get_node("sprites").get_children():
		sprite.visible = false
	get_node("sprites/" + anim_name).visible = true
	$AnimationPlayer.play(anim_name)

# Make eagor scream
func _scream() -> void:
	audio.play()

# Shake the screen
func _shake_screen(duration: float, frequency: float, amplitude: float) -> void:
	emit_signal("shake_screen", duration, frequency, amplitude)

# Spawn a basketball
func _spawn_ball() -> void:
	for balls in STAGE_VARIABLES[current_stage].ball_attacks:
		var ball      = basketball.instance()
		var direction = Vector2(get_parent().scale.x, 0)
		var impulse   = direction * rand_range(ball_speed - 50, ball_speed + 50) * STAGE_VARIABLES[current_stage].speed
		get_parent().get_parent().get_parent().get_parent().get_parent().get_node("enemies").add_child(ball)
		
		ball.start_lifetime()
		ball.position = $ball_spawn.global_position
		ball.ball_force(direction, -impulse)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# Played at the end of the death animation
func boss_defeated() -> void:
	gui.on_player_level_cleared()
	emit_signal("_on_boss_defeated")

# If eagor hits the player, cause him to take damage
func _on_hitbox_arm_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		if global_position.x > body.global_position.x:
			body.set_velocity(Vector2(-3000, 0))
		else:
			body.set_velocity(Vector2(3000, 0))

# Used for detecting if the player is close
func _on_detection_body_entered(body: Node) -> void:
	if body.has_method("prepare_transition"):
		player_close = true
func _on_detection_body_exited(body: Node) -> void:
	if body.has_method("prepare_transition"):
		player_close = false

# Used to detect when the player has hit eagor
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hurt()
