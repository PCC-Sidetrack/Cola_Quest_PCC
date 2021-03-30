#-----------------------------------------------------------------------------#
# File Name:   eagor_movment.gd
# Description: The AI for the eagor boss fight
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 25, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var movement_machine:  AnimationNodeStateMachinePlayback = $boss_movement/AnimationTree.get("parameters/playback")
onready var animation_machine: AnimationNodeStateMachinePlayback = $paths/intro/boss_position/eagor/AnimationTree.get("parameters/playback")
onready var logic_machine:     AnimationNodeStateMachinePlayback = $boss_fight/AnimationTree.get("parameters/playback")
onready var eagor_current_position: PathFollow2D = $paths/intro/boss_position
onready var eagor_data = $paths/intro/boss_position/eagor

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _last_path: String = "intro"

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Thread Functions                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _player_close() -> void:
	print("player_close")
	if eagor_data.player_close:
		if not eagor_data.is_hurt:
			logic_machine.travel("swipe")
	else:
		if not eagor_data.is_hurt:
			logic_machine.travel("pick_action")

func _intro() -> void:
	print("intro")
	logic_machine.start("player_close")

func _delay() -> void:
	print("delay")
	yield(get_tree().create_timer(eagor_data.STAGE_VARIABLES[eagor_data.current_stage].delay), "timeout")
	logic_machine.travel("player_close")

func _swipe() -> void:
	print("swipe")
	animation_machine.travel("swipe")
	yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
	animation_machine.travel("idle")
	if not eagor_data.is_hurt:
		logic_machine.travel("player_close")

func _change_path(new_path: String) -> void:
	# Get the node for the new path
	var new_parent = $paths.get_node(new_path)
	# Disconnect eagor from its current path
	eagor_current_position.get_parent().remove_child(eagor_current_position)
	# Attach eagor to his new path
	new_parent.add_child(eagor_current_position)

func _jump() -> void:
	print("jump")
	animation_machine.travel("jump")
	if movement_machine.get_current_node() == "left":
		movement_machine.travel("right")
	else:
		movement_machine.travel("left")
	yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
	animation_machine.travel("idle")
	if not eagor_data.is_hurt:
		logic_machine.travel("delay")

func _idle() -> void:
	print("idle")
	animation_machine.travel("idle")
	yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
	if not eagor_data.is_hurt:
		logic_machine.travel("delay")

func _throw() -> void:
	print("throw")
	animation_machine.travel("throw")
	yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
	animation_machine.travel("idle")
	if not eagor_data.is_hurt:
		logic_machine.travel("delay")

func _pick_action() -> void:
	print("pick_action")
	var choice: int = rand_range(eagor_data.RANGE_MIN, eagor_data.RANGE_MAX)
	if choice >= eagor_data.RANGE_MAX - eagor_data.STAGE_VARIABLES[eagor_data.current_stage].jump_chance:
		if not eagor_data.is_hurt:
			print("jumping")
			logic_machine.travel("jump")
	elif choice < eagor_data.STAGE_VARIABLES[eagor_data.current_stage].throw_chance:
		if not eagor_data.is_hurt:
			print("throwing")
			logic_machine.travel("throw")
	else:
		if not eagor_data.is_hurt:
			print("idling")
			logic_machine.travel("idle")

func _is_dead() -> void:
	print("is_dead")
	if eagor_data.is_dead():
		logic_machine.travel("death")
	else:
		animation_machine.travel("hurt")
		yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
		logic_machine.travel("end_of_stage")

func _end_of_stage() -> void:
	print("end_of_stage")
	if eagor_data.get_current_health() <= 0:
		animation_machine.travel("jump")
		movement_machine.travel("scaffold")
		yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
		animation_machine.travel("idle")
		logic_machine.travel("summon")
	else:
		logic_machine.travel("player_close")

func _death() -> void:
	print("death")
	animation_machine.travel("death")

func _summon() -> void:
	print("summon")
	animation_machine.travel("summon")
	# Code to summon enemies
	print("summoning")
	yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
	logic_machine.travel("enemies_dead")

func _enemies_dead() -> void:
	print("enemies_dead")
	if get_tree().get_node("entities/enemies").get_child_count() <= 0 and eagor_data.current_wave == eagor_data.STAGE_VARIABLES[eagor_data.current_stage].waves:
		animation_machine.travel("roar")
		yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
		animation_machine.travel("jump")
		movement_machine.travel("center")
		yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
		animation_machine.travel("jump")
		if randf() >= 0.5:
			movement_machine.travel("left")
		else:
			movement_machine.travel("right")
		yield(get_tree().create_timer(eagor_data.get_node("AnimationPlayer").get_animation(animation_machine.get_current_node()).length - 0.5), "timeout")
		logic_machine.travel("player_close")
	elif get_tree().get_node("entities/enemies").get_child_count() <= 0 and eagor_data.current_wave < eagor_data.STAGE_VARIABLES[eagor_data.current_stage].waves:
		eagor_data.current_wave += 1
		logic_machine.travel("summon")
	else:
		animation_machine.travel("idle")
		logic_machine.travel("enemies_dead")

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_eagor_eagor_hit() -> void:
	logic_machine.travel("is_dead")
