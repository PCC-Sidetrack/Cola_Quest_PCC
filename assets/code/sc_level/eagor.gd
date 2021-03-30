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
signal _done_attacking
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
		delay        = 1.5,
		idle_chance  = 45,
		jump_chance  = 20,
		speed        = 1.0,
		throw_chance = 35,
		waves        = 1,
	},
	2: {
		ball_attacks = 1,
		delay        = 1.2,
		idle_chance  = 35,
		jump_chance  = 20,
		speed        = 1.2,
		throw_chance = 45,
		waves        = 2,
	},
	3: {
		ball_attacks = 2,
		delay        = 0.5,
		idle_chance  = 25,
		jump_chance  = 30,
		speed        = 1.5,
		throw_chance = 45,
	},
}

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var ball_speed: int = 100
export var damage:     int = 1
export(int, 1, 5)      var full_health = 3
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
onready var audio         = $AudioStreamPlayer2D
onready var basketball    = preload("res://assets/code/sprite_scenes/basketball.tscn")
onready var animation_machine = $AnimationTree.get("parameters/playback")

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
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
func get_current_health() -> int:
	return _current_health

func hurt() -> void:
	emit_signal("eagor_hit")

# Move eagor to the next stage in the fight
func next_stage() -> void:
	if current_stage < TOTAL_STAGES:
		current_stage += 1

func start_fight() -> void:
	animation_machine.start("idle")

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _emit_particles(is_emitting: bool) -> void:
	$particles/bolts.emitting = is_emitting
	$particles/nuts.emitting  = is_emitting

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
	return (_current_health == 0 and current_stage == 3)

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
		get_tree().get_root().add_child(ball)
		
		ball.start_lifetime()
		ball.position = $ball_spawn.global_position
		ball.ball_force(direction, -impulse)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# Played at the end of the death animation
func boss_defeated() -> void:
	emit_signal("_on_boss_defeated")

# If eagor hits the player, cause him to take damage
func _on_hitbox_arm_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and area.is_in_group("hurtbox"):
		area.get_parent().take_damage(damage)
		if global_position.x > area.global_position.x:
			area.get_parent().set_velocity(Vector2(-30, 0))
		else:
			area.get_parent().set_velocity(Vector2(30, 0))

func _on_detection_area_entered(_area: Area2D) -> void:
	player_close = true

func _on_detection_area_exited(_area: Area2D) -> void:
	player_close = false

