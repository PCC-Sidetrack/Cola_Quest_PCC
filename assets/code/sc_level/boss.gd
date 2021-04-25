#-----------------------------------------------------------------------------#
# File Name:   boss.gd
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
onready var animation_player:       AnimationTree                     = $paths/intro/boss_position/eagor/AnimationTree
onready var movement_machine:       AnimationNodeStateMachinePlayback = $boss_movement/AnimationTree.get("parameters/playback")
onready var animation_machine:      AnimationNodeStateMachinePlayback = $paths/intro/boss_position/eagor/AnimationTree.get("parameters/playback")
onready var logic_machine:          AnimationNodeStateMachinePlayback = $boss_fight/AnimationTree.get("parameters/playback")
onready var eagor_current_position: PathFollow2D                      = $paths/intro/boss_position
onready var eagor_data:             StaticBody2D                      = $paths/intro/boss_position/eagor

onready var flying_eagor:           Resource                          = preload("res://assets/sprite_scenes/sc_level/flying_eagor.tscn")

onready var right_point:            Position2D                        = $points/right_floor
onready var left_point:             Position2D                        = $points/left_floor
onready var center_point:           Position2D                        = $points/center_floor
onready var scaffold:               Position2D                        = $points/scaffold

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
#var _last_path: String = "intro"

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
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
# The code for the change path node
func _change_path(new_path: String) -> void:
	# Get the node for the new path
	var new_parent = $paths.get_node(new_path)
	# Disconnect eagor from its current path
	eagor_current_position.get_parent().remove_child(eagor_current_position)
	# Attach eagor to his new path
	new_parent.add_child(eagor_current_position)

# The code for the death node
func _death() -> void:
	var game_ui = Globals.player.get_node("game_UI")
	
	#print("death")
	Globals.game_locked = true
	Globals.player.set_obeys_gravity(false)
	Globals.player.set_velocity(Vector2.ZERO)
	
	for ball in get_owner().get_node("entities/enemies").get_children():
		ball.queue_free()
	
	$boss_fight/AnimationTree.active = false
	animation_player.active          = false
	animation_machine.stop()
	eagor_data._play_animation("death")
	
	Globals.stop_highscore_timer()
	var score = Globals.calculate_highscore(game_ui.get_cola_count(), Globals.get_highscore_timer(), game_ui.get_respawn_count())
	
	Globals.update_highscore_file_from_local()
	var previous_score = Globals.get_highscore_dictionary().sports_center
	
	if Globals.get_highscore_dictionary().sports_center < score:
		Globals.update_sc_score(score)
	
	game_ui.on_player_level_cleared(previous_score)
	
# The code for the delay node
func _delay() -> void:
	#print("delay")
	yield(get_tree().create_timer(eagor_data.STAGE_VARIABLES[eagor_data.current_stage].delay), "timeout")
	if logic_machine.get_current_node() == "delay":
		logic_machine.travel("player_close")

# The code for the end of stage node
func _end_of_stage() -> void:
	#print("end_of_stage")
	if eagor_data.get_current_health() <= 0:
		eagor_data.current_wave = 1
		animation_machine.travel("jump")
		movement_machine.travel("scaffold")
		yield(get_tree().create_timer(0.5), "timeout")
		animation_machine.travel("idle")
		yield(get_tree().create_timer(1.0), "timeout")
		if logic_machine.get_current_node() == "end_of_stage":
			logic_machine.travel("summon")
	else:
		if logic_machine.get_current_node() == "end_of_stage":
			logic_machine.travel("player_close")

# The code for the enemies dead node
func _enemies_dead() -> void:
	#print("enemies_dead")
	if get_node("../enemies").get_child_count() <= 0 and eagor_data.current_wave >= eagor_data.STAGE_VARIABLES[eagor_data.current_stage].waves:
		animation_machine.travel("roar")
		yield(get_tree().create_timer(2.5), "timeout")
		if movement_machine.get_current_node() == "scaffold":
			animation_machine.travel("jump")
			if randf() >= 0.5:
				movement_machine.travel("left")
			else:
				movement_machine.travel("right")
			yield(get_tree().create_timer(1.0), "timeout")
			
		if logic_machine.get_current_node() == "enemies_dead":
			eagor_data.next_stage()
			logic_machine.travel("player_close")
	elif get_node("../enemies").get_child_count() <= 0 and eagor_data.current_wave < eagor_data.STAGE_VARIABLES[eagor_data.current_stage].waves:
		eagor_data.current_wave += 1
		if logic_machine.get_current_node() == "enemies_dead":
			logic_machine.travel("summon")
	else:
		animation_machine.travel("idle")

# The code for the idle node
func _idle() -> void:
	#print("idle")
	animation_machine.travel("idle")
	yield(get_tree().create_timer(1.0), "timeout")
	if logic_machine.get_current_node() == "idle":
		logic_machine.travel("delay")

# The code for the intro node
func _intro() -> void:
	#print("intro")
	animation_machine.travel("idle")
	logic_machine.start("player_close")

# The code for the is dead node
func _is_dead() -> void:
	#print("is dead")
	if eagor_data.is_dead():
		if logic_machine.get_current_node() == "is_dead":
			logic_machine.travel("death")
	else:
		animation_machine.travel("hurt")
		#logic_machine.stop()
		yield(get_tree().create_timer(1.5), "timeout")
		#logic_machine.start("end_of_stage")
		if logic_machine.get_current_node() == "is_dead":
			logic_machine.travel("end_of_stage")

# The code for the jump node
func _jump() -> void:
	#print("jump")
	if not eagor_data.is_hurt:
		animation_machine.travel("jump")
		if movement_machine.get_current_node() == "left":
			movement_machine.travel("right")
		else:
			movement_machine.travel("left")
		yield(get_tree().create_timer(0.5), "timeout")
	
	if not eagor_data.is_hurt:
		animation_machine.travel("idle")
		if logic_machine.get_current_node() == "jump":
			logic_machine.travel("delay")

# The code for the pick action node
func _pick_action() -> void:
	#print("pick action")
	var choice: int = rand_range(eagor_data.RANGE_MIN, eagor_data.RANGE_MAX) as int
	if choice >= eagor_data.RANGE_MAX - eagor_data.STAGE_VARIABLES[eagor_data.current_stage].jump_chance:
		if logic_machine.get_current_node() == "pick_action":
			logic_machine.travel("jump")
	else:
		if logic_machine.get_current_node() == "pick_action":
			logic_machine.travel("throw")
	#else:
		#if logic_machine.get_current_node() == "pick_action":
		#	logic_machine.travel("idle")

# The code for the player close node
func _player_close() -> void:
	#print("player close")
	if eagor_data.player_close:
		if logic_machine.get_current_node() == "player_close":
			logic_machine.travel("swipe")
	else:
		if logic_machine.get_current_node() == "player_close":
			logic_machine.travel("pick_action")

# The code for the throw node
func _throw() -> void:
	#print("throw")
	animation_machine.travel("throw")
	yield(get_tree().create_timer(1.5 / eagor_data.STAGE_VARIABLES[eagor_data.current_stage].speed), "timeout")
	animation_machine.travel("idle")
	if logic_machine.get_current_node() == "throw":
		logic_machine.travel("delay")

# The code for the summon node
func _summon() -> void:
	#print("summon")
	animation_machine.travel("summon")
	yield(get_tree().create_timer(1.0), "timeout")
	
	var eagor1 = flying_eagor.instance()
	var eagor2 = flying_eagor.instance()
	var eagor3 = flying_eagor.instance()
	
	eagor1.global_position = scaffold.global_position
	eagor2.global_position = scaffold.global_position
	eagor3.global_position = scaffold.global_position
	
	get_node("../enemies").add_child(eagor1)
	yield(get_tree().create_timer(1.0), "timeout")
	get_node("../enemies").add_child(eagor2)
	yield(get_tree().create_timer(1.0), "timeout")
	get_node("../enemies").add_child(eagor3)
	yield(get_tree().create_timer(1.0), "timeout")
	
	if logic_machine.get_current_node() == "summon":
		logic_machine.travel("enemies_dead")

# The code for the swipe node
func _swipe() -> void:
	#print("swipe")
	animation_machine.travel("swipe")
	yield(get_tree().create_timer(2.0 / eagor_data.STAGE_VARIABLES[eagor_data.current_stage].speed), "timeout")
	animation_machine.travel("idle")
	if logic_machine.get_current_node() == "swipe":
		logic_machine.travel("player_close")

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# Has eagor gotten hit
func _on_eagor_eagor_hit() -> void:
	logic_machine.stop()
	logic_machine.start("is_dead")
