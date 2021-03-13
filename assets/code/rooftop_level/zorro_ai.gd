#-----------------------------------------------------------------------------#
# Class Name:   zorro_ai
# Description:  Holds the code used to control the ai for the Zorro boss.
#               Also holds comments to give an understanding of using the AI class
#               that this code inherits.
# Author:       Andrew
# Company:      Sidetrack
# Last Updated: 3/5/2021
#-----------------------------------------------------------------------------#

extends AI

#-----------------------------------------------------------------------------#
#                              Private Constants                              #
#-----------------------------------------------------------------------------#

# Enums for animations - Array Structure: [animation_name, corresponding_sprite_name]
var _ANIMATION: Dictionary = {
	IDLE          = ["idle_sword", "idle"],
	IDLE_NO_SWORD = ["idle_no_sword", "idle"],
	ARM_WAVE      = ["arm_wave", "arm_wave"],
	DRAW_SWORD    = ["draw_sword", "draw_sword"],
	SHEATH_SWORD  = ["sheath_sword", "draw_sword"],
	JUMP          = ["jump_sword", "jump"],
	JUMP_NO_SWORD = ["jump_no_sword", "jump"],
	ATTACK        = ["sword_attack", "sword_attack"],
	THROW         = ["throw", "throw"],
	WALK          = ["walk_sword", "walk"],
	WALK_NO_SWORD = ["walk_no_sword", "walk"]
}

# Holds a reference to the 3x5_projectile scene
const _STUDY_CARD = preload("res://assets//sprite_scenes//rooftop_scenes//study_card_projectile.tscn")


#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Controls whether zorro obeys gravity
export var obeys_gravity:                 bool  = true
# Controls whether zorro accelerates into movement or not
export var smooth_movement:               bool  = true
# Controls whether zorro uses entity.gd's auto facing or custom code
export var auto_facing:                   bool  = false

# Controls the acceleration of movement if smooth_movement is turned on
export var acceleration:                  float = 20.0
# Speed at which zorro jumps
export var jump_speed:                    float = 850.0
# Speed at which zorro moves
export var speed:                         float = 5.0
# Multiplier applied to speed for dashing
export var dash_multiplier:               float = 4.0

# Indicates the cooldown for attacking (in seconds)
export var attack_cooldown:               float = 1.5
# Indicates the cooldown for dashing (in seconds)
# Should be same as or less than attack cooldown if used in an attack action
export var dash_cooldown:                 float = attack_cooldown

# Damage that zorro deals to entitys
export var damage:                        int = 1
# Max health of boss
export var max_health:                    int = 16
# Distance of boss from player before an action occurs (such as an attack)
export var standard_distance_from_player: int = 130


#-----------------------------------------------------------------------------#
#                               Public Variables                              #
#-----------------------------------------------------------------------------#
# Used to determine if the boss fight is currently enabled (for performance)
var fight_enabled: bool  = false

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Holds the current animation being shown
var _current_animation:             Array = _ANIMATION.IDLE

# Tracks attack cooldown using delta (time in seconds)
var _attack_cooldown_timer:         float = 0.0
# Wait cooldown
var _wait_cooldown:                 float = 7.0
# Tracks the wait cooldown
var _wait_cooldown_timer:           float = 0.0
# Jump cooldown
var _jump_cooldown:                 float = 0.5
# Tracks jump cooldown
var _jump_cooldown_timer:           float = 0.0
# Second, longer jump cooldown
var _secondary_jump_cooldown:       float = 1.5
# Tracks second, longer jump cooldown
var _secondary_jump_cooldown_timer: float = 0.0
# Turnaround cooldown for when player is behind ai
var _attack_turnaround_cooldown:    float = 1.0
# Tracks turnaround timer for when player is behind ai
var _attack_turnaround_timer:       float = 0.0
# Jump attack cooldown for when player is behind ai
var _jump_attack_cooldown:          float = 1.0
# Tracks Jump attack timer for when player is behind ai
var _jump_attack_timer:             float = 0.0
# Throw 3x5 card cooldown
var _throw_card_cooldown:           float = 1.5
# Tracks throw 3x5 card timer
var _throw_card_timer:              float = 1.0



# Tracks the id of the scaffolding the ai is currently within (horizontally).
# id 0: ai is not within any scaffolding
# id 1: ai is within scaffolding_left
# id 2: ai is within scaffolding_middle_left
# id 3: ai is within scaffolding_middle_right
# id 4: ai is within scaffolding_right
var _scaffolding_id:                int = 0

# Tracks whether the ai has already decided (while within a scaffolding position)
# to jump or not
var _decided_jump:                  bool = false

# Used for generating random numbers
var _rng:                           RandomNumberGenerator = RandomNumberGenerator.new()

# Holds a Timer that can be used throughout the class
var _timer:                         Timer = Timer.new()

#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#
# Used to hold the points for the boss fight
onready var _points:                Node = get_node("../../points/boss_fight")


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialize the boss
	initialize(max_health, damage, speed, acceleration, jump_speed, dash_cooldown, obeys_gravity, smooth_movement, auto_facing)
	get_owner().get_node("player/game_UI").on_initialize_boss (max_health, "Dr. Zorro")
	
	# Set the initial animation to play
	_change_animation(_ANIMATION.IDLE)
	
	add_child(_timer)
	_timer.set_one_shot(true)
	
	# Randomize the seed of the random number generator
	_rng.randomize()
	
# Runs every physics engine update
func _physics_process(delta) -> void:
	# Update cooldown timers
	if _attack_cooldown_timer < attack_cooldown:
		_attack_cooldown_timer += delta
	if _wait_cooldown_timer < _wait_cooldown:
		_wait_cooldown_timer += delta
	if _jump_cooldown_timer < _jump_cooldown:
		_jump_cooldown_timer += delta
	if _secondary_jump_cooldown_timer < _secondary_jump_cooldown:
		_secondary_jump_cooldown_timer += delta
	if _attack_turnaround_timer < _attack_turnaround_cooldown:
		_attack_turnaround_timer += delta
	if _jump_attack_timer < _jump_attack_cooldown:
		_jump_attack_timer += delta
	if _throw_card_timer < _throw_card_cooldown:
		_throw_card_timer += delta

#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#

# Change the animation of the sprite giving a string from the _ANIMATION dictionary.
func _change_animation(animation: Array) -> void:
	# Only perform a change if the animation given isn't already running
	if animation != _current_animation:
		# Make sure the integer given is in the dictionary. If not, give a warning.
		if animation in _ANIMATION.values():
			_current_animation = animation
			
			# First set all the zorro sprites to invisible
			for sprite in $sprites.get_children():
				sprite.visible = false
					
			# Set the correct sprite to visible and play the animation
			$sprites.get_node(_current_animation[1]).visible = true
			$AnimationPlayer.stop()
			$AnimationPlayer.play(_current_animation[0])
			
		else:	
			ProgramAlerts.add_warning("In boss fight AI, attempted to change an animation to non-existant animation id.")

# Detects if the ai is currently facing the player
func _ai_facing_player() -> bool:
	# Holds the return value
	var facing_player: bool = false
	
	# If moving right and player is to the right then ai is facing player
	if get_movement_direction().x == DIRECTION.RIGHT.x and global_position.x < Globals.player_position.x:
		facing_player = true
	# Else if moving left and player is to the left then ai is facing player
	if get_movement_direction().x == DIRECTION.LEFT.x and global_position.x > Globals.player_position.x:
		facing_player = true
	
	return facing_player

# Detects and sets the current state of the ai
func _detect_state() -> int:
	# Used to decide whether to detect the state of the ai or use the state stack
	var detect_state:        bool = true
	# Used to hold the detected state of the ai
	var state_detected:      int  = STATE.NONE
	# Used to temporarily keep track of a state
	var temp_state_detected: int  = STATE.NONE
	
	# Order for checking state. If a state is detected, then don't continue checking
	# for the next state:
	# Check for saved states in the state stack (the state stack is being used to
	# 	set the ai state for future cycles of _detect_state()
	# Check for attacks
	# Check for movements (if not attacking)
	# Check for jump      (if movement is happening)
	# Check for waiting   (if movement is happening and jump is not happening)
	
	temp_state_detected = pop_state_stack()
	
	# If the state stack is not empty, then set the detected state to whatever
	# state was popped off the stack
	if temp_state_detected != null:
		# If the state popped is to jump, then make sure the jump cooldown is ready.
		if temp_state_detected == STATE.JUMPING:
			if _jump_cooldown_timer >= _jump_cooldown:
				state_detected = temp_state_detected
				detect_state   = false
			# If the cooldown isn't ready and the ai hasn't left the scaffolding area,
			# then re-add the command to the stack and continue detecting the state of the ai
			elif _scaffolding_id != 0:
				push_state_stack(temp_state_detected)
		# If the state popped is not jumping, set the state detected to the temp_state_detected
		else:
			state_detected = temp_state_detected
			detect_state   = false
			
	# If while looking at the state stack the decision to detect the state was not
	# set to false, then detect the state of the ai.
	if detect_state:
		# Check for attack state
		state_detected = _detect_attack_state()
		
		# If the current state isn't one of the attacking states, then determine other possible states
		if state_detected == STATE.NONE:
			# Detect what movement state should be set
			state_detected = _detect_movement_state()
			
			# If returns a jumping state, then state_detected will change from the movement state to jumping state
			temp_state_detected = _detect_jumping_state()
			if temp_state_detected != STATE.NONE:
				state_detected      = temp_state_detected
				temp_state_detected = STATE.NONE
			
			# If not jumping, then detect whether a wait should occur
			if state_detected != STATE.JUMPING:
				temp_state_detected = _detect_waiting_state()
				if temp_state_detected != STATE.NONE:
					state_detected = temp_state_detected
					temp_state_detected = STATE.NONE
				
	return state_detected

# Returns an attack state if criteria is met. Otherwise returns the current state of the ai.
func _detect_attack_state() -> int:
	# Holds the height of the collision shape of the player
	var player_height:  float = Globals.player.get_node("CollisionShape2D").get_shape().extents.y
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int   = STATE.NONE
	
	# Custom key:
	# ATTACKING1: player is directly in front of ai
	# ATTACKING2: player is directly behind ai
	# ATTACKING3: player is in front and above of ai
	# ATTACKING4: player is behind and above ai
	# ATTACKING5: player is in front and below ai
	# ATTACKING6: player is behind and below ai
	
	# If player is to the right of the ai
	if global_position.x - Globals.player_position.x <= standard_distance_from_player and global_position.x - Globals.player_position.x >= 0:
		# If ai is facing left
		if get_movement_direction().x == DIRECTION.LEFT.x:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING1
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING1
			# If player is within horizontal range and is above/below in vertical range
			elif abs(global_position.y - Globals.player_position.y) <= player_height * 4:
				# If player is above ai
				if Globals.player_position.y < global_position.y:
					state_detected = STATE.ATTACKING3
				# If player is below ai
				else:
					state_detected = STATE.ATTACKING5
			
		# If ai is facing right or is not currently moving
		else:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING2
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING2
			# If player is within horizontal range and is above/below in vertical range
			elif abs(global_position.y - Globals.player_position.y) <= player_height * 4:
				# If player is above ai
				if Globals.player_position.y < global_position.y:
					state_detected = STATE.ATTACKING4
				# If player is below ai
				else:
					state_detected = STATE.ATTACKING6
			
	# If player is to the left of the ai
	elif global_position.x - Globals.player_position.x >= -standard_distance_from_player and global_position.x - Globals.player_position.x <= 0:
		# If ai is facing left
		if get_movement_direction().x == DIRECTION.LEFT.x:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING2
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING2
			# If player is within horizontal range and is above/below in vertical range
			elif abs(global_position.y - Globals.player_position.y) <= player_height * 4:
				# If player is above ai
				if Globals.player_position.y < global_position.y:
					state_detected = STATE.ATTACKING4
				# If player is below ai
				else:
					state_detected = STATE.ATTACKING6
			
		# If ai is facing right or is not currently moving
		else:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING1
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING1
			# If player is within horizontal range and is above/below in vertical range
			elif abs(global_position.y - Globals.player_position.y) <= player_height * 4:
				# If player is above ai
				if Globals.player_position.y < global_position.y:
					state_detected = STATE.ATTACKING3
				# If player is below ai
				else:
					state_detected = STATE.ATTACKING5
	
	return state_detected

# Returns a movement state based on location and current state of the ai
func _detect_movement_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int = STATE.NONE
	
	# Custom key:
	# MOVING1:  moving left
	# MOVING2:  moving right
			
	# Check for a condition that would cause movement direction to change
	if is_on_wall():
		# If currently moving to the right, move left
		if get_movement_direction().x == DIRECTION.RIGHT.x:
			state_detected = STATE.MOVING1
		# If currently moving to the left, move right
		else:
			state_detected = STATE.MOVING2
	# If not moving in any direction, pick a random direction
	elif get_current_state() == STATE.NONE:
		if _rng.randi_range(0, 1):
			state_detected = STATE.MOVING1
		else:
			state_detected = STATE.MOVING2
	# If not on a wall and is moving left or right, then set the detected state to
	# whatever the state currently is.
	else:
		if get_movement_direction().x == DIRECTION.LEFT.x:
			state_detected = STATE.MOVING1
		else:
			state_detected = STATE.MOVING2
	
	return state_detected

# Returns the jumping state if criteria is met. Otherwise returns the current state of the ai.
func _detect_jumping_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int = STATE.NONE
	
	# Check if within scaffolding 
	if !_decided_jump and _scaffolding_id != 0 and _scaffolding_id != 2 and _jump_cooldown_timer >= _jump_cooldown:
		# Randomly decide to jump or not jump
		# 1 in 3 chance of jumping
		if !(_rng.randi_range(0, 2)):
			state_detected = STATE.JUMPING
			
		_decided_jump = true
			
	return state_detected

# Returns the waiting state if criteria is met. Otherwise returns the current state of the ai.
func _detect_waiting_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int = STATE.NONE
	
	# Custom key:
	# WAITING1: wait
	
	# If the current state is one of the movement states, then randomly decide to wait or not
	# Only randomly decide to wait if the cooldown is past
	if _wait_cooldown_timer >= _wait_cooldown:
		# 1 in 4 chance for the ai to wait
		if _rng.randi_range(0, 3):
			state_detected = STATE.WAITING1
			
		# Regardless of decision, reset the cooldown timer
		_wait_cooldown_timer = 0.0
	
	return state_detected
	
# Detects and (if needed) changes the current stage of the ai
func _detect_stage() -> void:
	pass
	
# Get the current floor of scaffolding the ai is on.
# -1 = not in scaffolding, 0 = ground, 1 = 1st floor, 2 = 2nd floor, etc.
func _get_scaffolding_floor() -> int:
	# Holds the scaffolding floor, default value of -1 (not in scaffolding)
	var scaffolding_floor = -1
	
	match _scaffolding_id:
		1: # scaffolding_left
			# Check from ground floor up for which floor ai is on
			if global_position.y >= _points.get_node("scaffolding_left/level1/left_side").global_position.y:
				scaffolding_floor = 0
			elif global_position.y >= _points.get_node("scaffolding_left/level2/left_side").global_position.y:
				scaffolding_floor = 1
			elif global_position.y >= _points.get_node("scaffolding_left/level3/left_side").global_position.y:
				scaffolding_floor = 2
			else:
				scaffolding_floor = 3
		2: # scaffolding_middle_left
			# Check from ground floor up for which floor ai is on
			if global_position.y >= _points.get_node("scaffolding_middle_left/left_side").global_position.y:
				scaffolding_floor = 0
			else:
				scaffolding_floor = 1
		3: # scaffolding_middle_right
			# Check from ground floor up for which floor ai is on
			if global_position.y >= _points.get_node("scaffolding_middle_right/level1/left_side").global_position.y:
				scaffolding_floor = 0
			elif global_position.y >= _points.get_node("scaffolding_middle_right/level2/left_side").global_position.y:
				scaffolding_floor = 1
			elif global_position.y >= _points.get_node("scaffolding_middle_right/level3/left_side").global_position.y:
				scaffolding_floor = 2
			elif global_position.y >= _points.get_node("scaffolding_middle_right/level4/left_side").global_position.y:
				scaffolding_floor = 3
			else:
				scaffolding_floor = 4
		4: # scaffolding_right
			# Check from ground floor up for which floor ai is on
			if global_position.y >= _points.get_node("scaffolding_right/level1/left_side").global_position.y:
				scaffolding_floor = 0
			elif global_position.y >= _points.get_node("scaffolding_right/level2/left_side").global_position.y:
				scaffolding_floor = 1
			elif global_position.y >= _points.get_node("scaffolding_right/level3/left_side").global_position.y:
				scaffolding_floor = 2
			else:
				scaffolding_floor = 3
		_: # Not within scaffolding
			pass
	
	return scaffolding_floor
	
# Detects what scaffolding (if any) the ai is within (horizontally)
# Also sets to false whether the ai yet decided to or not to jump within this current scaffolding
func _check_within_scaffolding() -> void:
	# Check if ai is within scaffolding_left
	if global_position.x >= _points.get_node("scaffolding_left/level1/left_side").global_position.x and global_position.x <= _points.get_node("scaffolding_left/level1/right_side").global_position.x:
		if _scaffolding_id != 1:
			_scaffolding_id = 1
			_decided_jump   = false
	# Check if ai is within scaffolding_middle_left
	elif global_position.x >= _points.get_node("scaffolding_middle_left/left_side").global_position.x and global_position.x <= _points.get_node("scaffolding_middle_left/right_side").global_position.x:
		if _scaffolding_id != 2:
			_scaffolding_id = 2
			_decided_jump   = false
	# Check if ai is within scaffolding_middle_right
	elif global_position.x >= _points.get_node("scaffolding_middle_right/level1/left_side").global_position.x and global_position.x <= _points.get_node("scaffolding_middle_right/level1/right_side").global_position.x:
		if _scaffolding_id != 3:
			_scaffolding_id = 3
			_decided_jump   = false
	# Check if ai is within scaffolding_right
	elif global_position.x >= _points.get_node("scaffolding_right/level1/left_side").global_position.x and global_position.x <= _points.get_node("scaffolding_right/level1/right_side").global_position.x:
		if _scaffolding_id != 4:
			_scaffolding_id = 4
			_decided_jump   = false
	# Otherwise ai is not within scaffolding
	else:
		if _scaffolding_id != 0:
			_scaffolding_id = 0
			_decided_jump   = false
	
# Code for the ai run during stage one of the fight
func _run_ai_stage_one() -> void:
	# STAGE ONE INSTRUCTIONS:
	# Move left and right (bouncing off the wall) until near the player's x value
	# If player's y value is within a range of enemy's own y value, then perform
	# a sword attack.
	# If not, check if inside a scaffolding area. If inside scaffolding area, jump up
	# and check again at the top of the jump for the x and y locations. Repeat top steps
	# until close to the player. When y value and x value are close to the player, make
	# a sword attack
	
	# If the current state isn't none, then enable movement
	if get_current_state() != STATE.NONE:
		set_movement_enabled(true)
	
	# Perform actions depending upon the current state
	match get_current_state():
		STATE.ATTACKING1: # ATTACKING1: player is directly in front of ai
			attack()
		STATE.ATTACKING2: # ATTACKING2: player is directly behind ai
			# Within intervals of time, randomly decide to turn around
			if _attack_turnaround_timer >= _attack_turnaround_cooldown:
				if !_rng.randi_range(0, 2):
					turn_around()
				_attack_turnaround_timer = 0.0
		STATE.ATTACKING3: # ATTACKING3: player is in front and above of ai
			if _jump_attack_timer >= _jump_attack_cooldown:
				_zorro_jump()
				_jump_attack_timer = 0.0
		STATE.ATTACKING4: # ATTACKING4: player is behind and above ai
			pass
		STATE.ATTACKING5: # ATTACKING5: player is in front and below ai
			pass
		STATE.ATTACKING6: # ATTACKING6: player is behind and below ai
			pass
		STATE.MOVING1: # MOVING1:  moving left
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.LEFT)
		STATE.MOVING2: # MOVING2:  moving right
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.RIGHT)
		STATE.JUMPING:
			pass
		STATE.WAITING1:
			_taunt()
		_:
			pass

# Code for the ai run during stage two of the fight
func _run_ai_stage_two() -> void:
	# STAGE TWO INSTRUCTIONS:
	# Steal some of the player's hp (one hit point which will translate to 3 for him)
	# Spawn in some moving drones to make the parkour more difficult for the player.
	# Move left and right trying to avoid the player, stopping every once in a while
	# to play the taunting animation.
	# If in a place to jump on the scaffolding, then make a random decision to do so
	# or not.
	# Stop every once in a while and throw a 3x5 card at the player.
	
	# If the current state isn't none, then enable movement
	if get_current_state() != STATE.NONE:
		set_movement_enabled(true)
	
	# Perform actions depending upon the current state
	match get_current_state():
		STATE.ATTACKING1: # ATTACKING1: player is directly in front of ai
			match _rng.randi_range(0, 3):
				0: # Turn around to run
					if _attack_turnaround_timer >= _attack_turnaround_cooldown:
						turn_around()
						_attack_turnaround_timer = 0.0
				1: # Throw a 3x5 card
					_throw_card()
				_: # Jump and dash over the player's head
					if _dash_cooldown_timer >= _dash_cooldown:
						# Jump
						_zorro_jump(true)
						_timer.start(0.2)
						yield(_timer, "timeout")
						
						# Set the velocity (simialar to how it's done in entity.gd)
						_change_animation(_ANIMATION.JUMP)
						set_ai_velocity(Vector2(get_movement_direction().x * get_ai_speed() * _dash_multiplier * 2, get_ai_velocity().y))
						_timer.start(0.2)
						yield(_timer, "timeout")
						_dash_cooldown_timer = 0.0
						_change_animation(_ANIMATION.WALK)
			
		STATE.ATTACKING2: # ATTACKING2: player is directly behind ai
			
			match _rng.randi_range(0, 3):
				0: # Dash
					if _dash_cooldown_timer >= _dash_cooldown:	
						# Set the velocity (simialar to how it's done in entity.gd)
						_change_animation(_ANIMATION.JUMP)
						set_ai_velocity(Vector2(get_movement_direction().x * get_ai_speed() * _dash_multiplier, get_ai_velocity().y))
						_timer.start(0.2)
						yield(_timer, "timeout")
						_dash_cooldown_timer = 0.0
						_change_animation(_ANIMATION.WALK)
				1: # Turn around, jump, and dash over the players head
					if _dash_cooldown_timer >= _dash_cooldown:
						# Turnaround
						turn_around()
						
						# Jump
						_zorro_jump(true)
						_timer.start(0.2)
						yield(_timer, "timeout")
						
						# Set the velocity (simialar to how it's done in entity.gd)
						_change_animation(_ANIMATION.JUMP)
						set_ai_velocity(Vector2(get_movement_direction().x * get_ai_speed() * _dash_multiplier * 2, get_ai_velocity().y))
						_timer.start(0.2)
						yield(_timer, "timeout")
						_dash_cooldown_timer = 0.0
						_change_animation(_ANIMATION.WALK)
				_: # Jump and dash
					if _dash_cooldown_timer >= _dash_cooldown:
						_zorro_jump(true)
						_timer.start(0.2)
						yield(_timer, "timeout")
						
						# Set the velocity (simialar to how it's done in entity.gd)
						_change_animation(_ANIMATION.JUMP)
						set_ai_velocity(Vector2(get_movement_direction().x * get_ai_speed() * _dash_multiplier, get_ai_velocity().y))
						_timer.start(0.2)
						yield(_timer, "timeout")
						_dash_cooldown_timer = 0.0
						_change_animation(_ANIMATION.WALK)
			
			# 66% chance to jump
			if _rng.randi_range(0, 2):
				_zorro_jump(true)
				_timer.start(0.2)
				yield(_timer, "timeout")
			else:
				_secondary_jump_cooldown_timer = 0.0
			
			# Randomly decide to jump and/or dash
			if !_rng.randi_range(0, 1):
				if _dash_cooldown_timer >= _dash_cooldown:
					# Set the velocity (simialar to how it's done in entity.gd)
					_change_animation(_ANIMATION.JUMP)
					set_ai_velocity(Vector2(get_movement_direction().x * get_ai_speed() * _dash_multiplier, get_ai_velocity().y))
					_timer.start(0.2)
					yield(_timer, "timeout")
					_dash_cooldown_timer = 0.0
					_change_animation(_ANIMATION.WALK)
		STATE.MOVING1: # MOVING1:  moving left
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.LEFT)
		STATE.MOVING2: # MOVING2:  moving right
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.RIGHT)
		STATE.JUMPING:
			pass
		STATE.WAITING1:
			_throw_card()
		_:
			pass

# Code for the ai run during stage three of the fight
func _run_ai_stage_three() -> void:
	# STAGE THREE INSTRUCTIONS:
	# If drone's aren't still there, respawn them. Also spawn in a few 3x5 shooting
	# drones.
	# Combine the ai from stages one and two so that Dr. Geary is trying to 
	# attack with the sword and occasionally throw's 3x5 cards as well.
	
	# If the current state isn't none, then enable movement
	if get_current_state() != STATE.NONE:
		set_movement_enabled(true)
	
	# Perform actions depending upon the current state
	match get_current_state():
		STATE.ATTACKING1: # ATTACKING1: player is directly in front of ai
			attack()
		STATE.ATTACKING2: # ATTACKING2: player is directly behind ai
			# Within intervals of time, randomly decide to turn around
			if _attack_turnaround_timer >= _attack_turnaround_cooldown:
				if !_rng.randi_range(0, 2):
					turn_around()
				_attack_turnaround_timer = 0.0
		STATE.ATTACKING3: # ATTACKING3: player is in front and above of ai
			if _jump_attack_timer >= _jump_attack_cooldown:
				_zorro_jump()
				_jump_attack_timer = 0.0
		STATE.ATTACKING4: # ATTACKING4: player is behind and above ai
			# Within intervals of time, randomly decide to turn around
			if _attack_turnaround_timer >= _attack_turnaround_cooldown and _jump_attack_timer >= _jump_attack_cooldown:
				if !_rng.randi_range(0, 2):
					_zorro_jump()
					turn_around()
				_attack_turnaround_timer = 0.0
				_jump_attack_timer       = 0.0
		STATE.ATTACKING5: # ATTACKING5: player is in front and below ai
			pass
		STATE.ATTACKING6: # ATTACKING6: player is behind and below ai
			pass
		STATE.MOVING1: # MOVING1:  moving left
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.LEFT)
		STATE.MOVING2: # MOVING2:  moving right
			_change_animation(_ANIMATION.WALK)
			set_movement_direction(DIRECTION.RIGHT)
		STATE.JUMPING:
			_zorro_jump()
		STATE.WAITING1:
			_throw_card()
		_:
			pass

# Code called when the boss fight is finished
func _finish_fight() -> void:
	pass
	
# Code for the ai jumping
func _zorro_jump(secondary_cooldown: bool = false) -> void:
	# Holds the number of floors on the scaffolding
	var num_floors = 0
	
	# Only check for a jump if the cooldown is not still counting
	if (_jump_cooldown_timer >= _jump_cooldown and !secondary_cooldown) or _secondary_jump_cooldown_timer >= _secondary_jump_cooldown and secondary_cooldown:
		# If jumping within scaffolding
		if _scaffolding_id != 0:
			# Determine the number of floors in the scaffolding
			if _scaffolding_id == 1 or _scaffolding_id == 4: # scaffolding_left or scaffolding_right
				num_floors = 3
			elif _scaffolding_id == 3: # scaffolding_middle_right
				num_floors = 4
				
			# Check if there's another floor above the ai and then
			# randomly decide to jump or not to jump add a jump to the state stack
			if _get_scaffolding_floor() < num_floors:
				if !_rng.randi_range(0, 2):
					push_state_stack(STATE.JUMPING)
		
		# For this ai cycle, perform one jump
		_change_animation(_ANIMATION.JUMP)
		jump()
		
		if secondary_cooldown:
			_secondary_jump_cooldown_timer = 0.0
		else:
			_jump_cooldown_timer = 0.0

# Draws or Sheaths the ai's sword
func _draw_sword(sheath: bool = false, ai_wait_add_time: bool = true) -> void:
	ai_wait(0.5, ai_wait_add_time)
	
	if sheath:
		# Have ai sheath sword
		_change_animation(_ANIMATION.SHEATH_SWORD)
		_timer.start(0.5)
		yield(_timer, "timeout")
	else:
		_change_animation(_ANIMATION.DRAW_SWORD)
		_timer.start(0.5)
		yield(_timer, "timeout")
	
# Code for the ai waiting
func _taunt() -> void:
	# Random value in seconds to wait
	var wait_time:     float = _rng.randf_range(0.5, 2.0)
	# Used to remember if the ai turned around to taunt the player
	var turned_around: bool  = false
	
	# If the ai is not facing the player before the taunt, then turn the ai around
	if !_ai_facing_player():
		turn_around()
		turned_around = true
	
	# Have ai sheath sword
	_draw_sword(true, false)
	
	# Set the ai to wait for the given amount of time while playing a taunting animation
	_change_animation(_ANIMATION.ARM_WAVE)
	ai_wait(wait_time)
	
	# Set the wait cooldown timer to negative wait_time so that it will
	# be impossible for a wait to occur again until after the waiting is
	# complete and the cooldown is complete after that
	_wait_cooldown_timer = -wait_time
	
	# If the ai turned around, turn it back around after the animation is done
	if turned_around:
		_timer.start(wait_time)
		yield(_timer, "timeout")
		turn_around()
		
	# Have the ai draw it's sword before continuing
	_draw_sword()

# Throws a 3x5 card at the player
func _throw_card() -> void:
	# Used to remember if the ai turned around to taunt the player
	var turned_around: bool   = false
	# Create, initialize, and add a new study card projectile to the drone
	var study_card:    Entity = _STUDY_CARD.instance()
	
	# Only throw the 3x5 card if the throw cooldown is finished
	if _throw_card_timer >= _throw_card_cooldown:
		
		# If the ai is not facing the player before the taunt, then turn the ai around
		if !_ai_facing_player():
			turn_around()
			turned_around = true
		
		# Have ai sheath sword
		_draw_sword(true)
		
		# Pause the ai for the duration of the throw
		ai_wait(0.5)
		
		# Perform the throwing animation
		_change_animation(_ANIMATION.THROW)
		_timer.start(0.5)
		yield(_timer, "timeout")
		
		# Spawn the 3x5 card
		# Save the position of the thrown 3x5 card to the misc_loc vector in Globals. It will
		# be used by the study card.
		Globals.misc_loc = Vector2($throw_point.global_position.x, $throw_point.global_position.y - (Globals.player.get_node("CollisionShape2D").get_shape().extents.y / 3))
		_points.get_node("study_card_parent").add_child(study_card)
		study_card.global_position = Globals.misc_loc
		study_card.speed = 7.0
		study_card.set_collision_mask_bit(Globals.LAYER.WORLD, false)
		study_card.initialize()
		
		# Have the ai taunt the player briefly
		_change_animation(_ANIMATION.ARM_WAVE)
		_timer.start(1.0)
		yield(_timer, "timeout")
		_change_animation(_ANIMATION.IDLE)
		
		# Have ai draw sword
		_draw_sword()
		
		# If the ai turned around, turn it back around after the animation is done
		if turned_around:
			turn_around()
			
		_throw_card_timer = 0.0

#-----------------------------------------------------------------------------#
#                                Signal Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# Signals that must be setup
#=============================
# Set initial values for use in boss ai here
func _on_zorro_boss_init() -> void:
	set_current_ai_stage(STAGE.TWO)
	set_movement_direction(DIRECTION.LEFT)
	set_current_state(STATE.MOVING2)

# Custom code for when the zorro boss attacks
# Change animations, set movement, etc
func _on_zorro_boss_attacked() -> void:
	if _attack_cooldown_timer >= attack_cooldown:
		# Immediatly set the cooldown to negative 10 seconds so that this method
		# isn't run again until it's complete. The cooldwon is reset to 0 seconds
		# at the end of the attack code
		_attack_cooldown_timer = -10.0
		
		# Play attack animation and wait until it is complete
		_change_animation(_ANIMATION.ATTACK)
		
		# To prepare it to dash in the correct direction (in case the ai movement is disabled
		# when this is called), the movement direction must be set towards the player
		if global_position.x - Globals.player_position.x > 0:
			set_movement_direction(DIRECTION.LEFT)
		else:
			set_movement_direction(DIRECTION.RIGHT)
		
		# Wait for 0.2 seconds
		_timer.start(0.2)
		yield(_timer, "timeout")
		
		# Perform the dash action then wait until the attack animation is complete
		dash()
		yield($AnimationPlayer, "animation_finished")
		
		# Have the ai wait with an idle animation for a bit
		_change_animation(_ANIMATION.IDLE)
		ai_wait(1.0, false)
	
		# Reset the attack cooldown (accounting for the ai waiting for one second
		_attack_cooldown_timer = -1.0

# This signal is sent whenever any stage is run
func _on_zorro_boss_stage_ran(stage_number):
	# Only run ai code if the fight is enabled
	if fight_enabled:
		# Pause ai.gd until ai code in this script is complete
		pause_ai()
		
		# If the current stage running is not STAGE.NONE then check statistics
		if stage_number != STAGE.NONE:
			_check_within_scaffolding()

		# Set the current state to the state returned by _detect_state
		set_current_state(_detect_state())

		# Run ai depending upon the stage
		match stage_number:
			STAGE.ONE:
				_run_ai_stage_one()
			STAGE.TWO:
				_run_ai_stage_two()
			STAGE.THREE:
				_run_ai_stage_three()
			STAGE.FOUR:
				_run_ai_stage_three()
			STAGE.FINISHED:
				_finish_fight()
			_:
				pass
				
		resume_ai()

#=============================
# Signals that must be setup if being used
#=============================

# Emitted after the ai turns aound either through turn_around() or set_movement_direcion()
# NOTE: If custom flip code is not desired (indicated in the initialize() function parameters)
#       then this signal does not need to have any code.
func _on_zorro_boss_turned_around(h_new_direction):
	# Flip all dr. geary sprites
	for child in get_node("sprites").get_children():
		if child is Sprite:
			child.scale.x *= -1
				
	# Flip the sword sprite and collision shape
	$sword.scale.x *= -1

#=============================
# Signals called after an action occurs
#============================= 
# Custom code for dashing (dash already does something but this allows addition
# of more code)
func _on_zorro_boss_dashed(multiplier):
	pass # Replace with function body.

# Emitted after the ai is paused. Also gives how long it is intended to be
# paused for (this holds true unless unpause_ai() is called)
func _on_zorro_boss_ai_paused(num_seconds) -> void:
	pass

# Emitted when the ai is resumed (after a pause)
func _on_zorro_boss_ai_resumed(was_waiting):
	if was_waiting:
		# Wait for the random wait time before resetting the wait cooldown
		_wait_cooldown_timer = 0.0

# Emitted after an ai_stage is made
func _on_zorro_boss_stage_changed(previous_stage, new_stage):
	pass # Replace with function body.

#=============================
# Signals not from ai.gd
#=============================

# Boss shouldn't be able to actually die
func _on_zorro_boss_death():
	$audio/sword_hit.play()
	set_current_ai_stage(STAGE.FINISHED)

func _on_zorro_boss_health_changed(ammount):
	get_owner().get_node("player/game_UI").on_boss_health_changed(get_current_health(), get_current_health() + ammount)
	if ammount < 0 and get_current_health():
		$audio/sword_hit.play()
		flash_damaged(10)
