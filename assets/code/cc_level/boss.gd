#-----------------------------------------------------------------------------#
# File Name:   boss.gd
# Description: The AI for the zacharias boss fight
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 25, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var zacharias_current_position = $paths/balcony_stage/boss_position
onready var zacharias_data             = $paths/balcony_stage/boss_position/zacharias

onready var animation_player           = $paths/balcony_stage/boss_position/zacharias/animation
onready var animation_machine          = $paths/balcony_stage/boss_position/zacharias/animation/animation_machine.get("parameters/playback")
onready var logic_player               = $logic
onready var logic_machine              = $logic/logic_machine.get("parameters/playback")
onready var movement_player            = $movement
onready var movement_machine           = $movement/movement_machine.get("parameters/playback")

onready var fireball

onready var gui = get_parent().get_parent().get_node("player/game_UI")

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var debugging: bool = false

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
#var _last_path: String = "balcony_stage"

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zacharias_current_position.unit_offset = 0
	$paths.visible = true

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
func start_fight() -> void:
	logic_machine.start("pick_action1")

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# The code for the change path node
func _change_path(new_path: String) -> void:
	# Get the node for the new path
	var new_parent = $paths.get_node(new_path)
	# Disconnect eagor from its current path
	zacharias_current_position.get_parent().remove_child(zacharias_current_position)
	# Attach eagor to his new path
	new_parent.add_child(zacharias_current_position)

# Stage 1 nodes
func _pick_action1() -> void:
	if debugging:
		print("pick_action1")
	
	var choice: int = randi() % 3
	
	if logic_machine.get_current_node() == "pick_action1":
		match choice:
			0:
				logic_machine.travel("jump")
			1:
				logic_machine.travel("fire")
			2:
				logic_machine.travel("punch")

func _jump() -> void:
	if debugging:
		print("jump")
	
	animation_machine.travel("jump")
	if movement_machine.get_current_node() == "p_stage_left":
		movement_machine.travel("p_stage_right")
	else:
		movement_machine.travel("p_stage_left")
	yield(get_tree().create_timer(animation_player.get_animation("jump").length), "timeout")
	
	if logic_machine.get_current_node() == "jump":
		logic_machine.travel("delay1")

func _punch() -> void:
	if debugging:
		print("punch")
	
	animation_machine.travel("punch")
	yield(get_tree().create_timer(animation_player.get_animation("punch").length), "timeout")
	
	if logic_machine.get_current_node() == "punch":
		logic_machine.travel("delay1")

func _fire() -> void:
	if debugging:
		print("fire")
	
	animation_machine.travel("fire")
	yield(get_tree().create_timer(animation_player.get_animation("fire").length), "timeout")
	
	if logic_machine.get_current_node() == "fire":
		logic_machine.travel("delay1")

func _delay1() -> void:
	if debugging:
		print("delay1")
	
	animation_machine.travel("idle1")
	yield(get_tree().create_timer(animation_player.get_animation("idle1").length), "timeout")
	
	if logic_machine.get_current_node() == "delay1":
		logic_machine.travel("pick_action1")

func _hit1() -> void:
	if debugging:
		print("hit1")
	
	animation_machine.travel("hit1")
	yield(get_tree().create_timer(animation_player.get_animation("hit1").length), "timeout")
	
	if logic_machine.get_current_node() == "hit1":
		logic_machine.travel("is_dead1")

func _is_dead1() -> void:
	if debugging:
		print("is_dead1")
	
	if logic_machine.get_current_node() == "is_dead1":
		if zacharias_data.stage_completed():
			zacharias_data.next_stage()
			
			if movement_machine.get_current_node() == "p_stage_right":
				movement_machine.travel("p_off_stage_right")
			else:
				movement_machine.travel("p_off_stage_left")
			yield(get_tree().create_timer(0.5), "timeout")
			
			animation_machine.travel("idle2")
			
			movement_machine.travel("p_upper_right")
			yield(get_tree().create_timer(0.5), "timeout")
			
			logic_machine.travel("delay2")
		else:
			logic_machine.travel("pick_action1")

# Stage 2 nodes
func _delay2() -> void:
	if debugging:
		print("delay2")
	
	animation_machine.travel("idle2")
	yield(get_tree().create_timer(animation_player.get_animation("idle2").length), "timeout")
	
	if logic_machine.get_current_node() == "delay2":
		logic_machine.travel("throw")

func _throw() -> void:
	if debugging:
		print("throw")
	
	animation_machine.travel("throw")
	yield(get_tree().create_timer(animation_player.get_animation("throw").length), "timeout")
	
	if logic_machine.get_current_node() == "throw":
		logic_machine.travel("delay2")

func _hit2() -> void:
	if debugging:
		print("hit2")
	
	animation_machine.travel("hit2")
	yield(get_tree().create_timer(animation_player.get_animation("hit2").length), "timeout")
	
	if logic_machine.get_current_node() == "hit2":
		logic_machine.travel("is_dead2")

func _is_dead2() -> void:
	if debugging:
		print("is_dead2")
	
	if logic_machine.get_current_node() == "is_dead2":
		if zacharias_data.stage_completed():
			zacharias_data.next_stage()
			
			movement_machine.travel("p_off_upper_right")
			yield(get_tree().create_timer(0.5), "timeout")
			
			animation_machine.travel("idle3")
			
			movement_machine.travel("p_upper_right")
			yield(get_tree().create_timer(0.5), "timeout")
			
			logic_machine.travel("pick_action3")
		else:
			logic_machine.travel("delay2")

# Stage 3 nodes
func _pick_action3() -> void:
	if debugging:
		print("pick_action3")
	
	if logic_machine.get_current_node() == "pick_action3":
		if randi() % 2 >= 1:
			logic_machine.travel("swoop")
		else:
			logic_machine.travel("gust")

func _gust() -> void:
	if debugging:
		print("gust")
	
	animation_machine.travel("gust")
	yield(get_tree().create_timer(animation_player.get_animation("gust").length), "timeout")
	
	if logic_machine.get_current_node() == "gust":
		logic_machine.travel("delay3")

func _delay3() -> void:
	if debugging:
		print("delay3")
	
	animation_machine.travel("idle3")
	yield(get_tree().create_timer(animation_player.get_animation("idle3").length), "timeout")
	
	if logic_machine.get_current_node() == "delay3":
		logic_machine.travel("pick_action3")

func _swoop() -> void:
	if debugging:
		print("swoop")
	
	if movement_machine.get_current_node() == "p_upper_right":
		movement_machine.travel("p_upper_left")
	else:
		movement_machine.travel("p_upper_right")
	
	animation_machine.travel("swoop")
	yield(get_tree().create_timer(animation_player.get_animation("swoop").length), "timeout")
	
	if logic_machine.get_current_node() == "swoop":
		logic_machine.travel("delay3")

func _hit3() -> void:
	if debugging:
		print("hit3")
	
	animation_machine.travel("hit3")
	yield(get_tree().create_timer(animation_player.get_animation("hit3").length), "timeout")
	
	if logic_machine.get_current_node() == "hit3":
		logic_machine.travel("is_dead3")

func _is_dead3() -> void:
	if debugging:
		print("is_dead3")
	
	if logic_machine.get_current_node() == "is_dead3":
		if zacharias_data.stage_completed():
			logic_machine.travel("death")
		else:
			logic_machine.travel("pick_action3")

# Boss fight end
func _death() -> void:
	if debugging:
		print("death")
	
	logic_player.get_node("logic_machine").active = false
	
	yield(get_tree().create_timer(animation_player.get_animation("death").length), "timeout")
	
	gui.on_player_level_cleared()



func note_hit(correct: bool) -> void:
	if correct:
		zacharias_data.invulnerable_flicker(50)
		zacharias_data.hurt()
		logic_machine.stop()
		logic_machine.start("hit2")


func _on_zacharias_boss_hit() -> void:
	zacharias_data.invulnerable_flicker(50)
	logic_machine.stop()
	match zacharias_data.current_stage:
		1:
			logic_machine.start("hit1")
		2:
			logic_machine.start("hit2")
		3:
			logic_machine.start("hit3")
