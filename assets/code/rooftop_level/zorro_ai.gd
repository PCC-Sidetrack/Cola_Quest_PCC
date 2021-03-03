#-----------------------------------------------------------------------------#
# Class Name:   zorro_ai
# Description:  Holds the code used to control the ai for the Zorro boss.
#               Also holds comments to give an understanding of using the AI class
#               that this code inherits.
# Author:       AUTH HERE
# Company:      Sidetrack
# Last Updated: DATE HERE
#-----------------------------------------------------------------------------#

extends AI

#-----------------------------------------------------------------------------#
#                              Private Constants                              #
#-----------------------------------------------------------------------------#
#=============================
# Dictionaries
#=============================

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

#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Controls whether zorro obeys gravity
export var obeys_gravity:   bool  = true
# Controls whether zorro accelerates into movement or not
export var smooth_movement: bool  = true
# Controls whether zorro uses entity.gd's auto facing or custom code
export var auto_facing:     bool  = false

# Controls the acceleration of movement if smooth_movement is turned on
export var acceleration:    float = 20.0
# Speed at which zorro jumps
export var jump_speed:      float = 850.0
# Speed at which zorro moves
export var speed:           float = 5.0
# Multiplier applied to speed for dashing
export var dash_multiplier: float = 3.0

# Indicates the cooldown for attacking (in seconds)
export var attack_cooldown: float = 1.0
# Indicates the cooldown for dashing (in seconds)
# Should be same as or less than attack cooldown if used in an attack action
export var dash_cooldown:   float = attack_cooldown

# Damage that zorro deals to entitys
export var damage:                        int = 1
# Max health of boss
export var max_health:                    int = 16
# Distance of boss from player before an action occurs (such as an attack)
export var standard_distance_from_player: int = 130

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Holds the current animation being shown
var _current_animation:     Array = _ANIMATION.IDLE

# Tracks attack cooldown using delta (time in seconds)
var _attack_cooldown_timer: float = 0.0
# Wait cooldown
var _wait_cooldown:         float = 5.0
# Tracks the wait cooldown
var _wait_cooldown_timer:   float = 0.0

# Tracks the id of the scaffolding the ai is currently within (horizontally).
# id 0: ai is not within any scaffolding
# id 1: ai is within scaffolding_left
# id 2: ai is within scaffolding_middle_left
# id 3: ai is within scaffolding_middle_right
# id 4: ai is within scaffolding_right
var _scaffolding_id:        int = 0

# Tracks whether the ai has already decided (while within a scaffolding position)
# to jump or not
var _decided_jump:          bool = false

# Used for generating random numbers
var _rng:                   RandomNumberGenerator = RandomNumberGenerator.new()

#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#
# Used to hold the points for the boss fight
onready var _points: Node = get_node("../../points/boss_fight")


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialize the boss
	initialize(max_health, damage, speed, acceleration, jump_speed, dash_cooldown, obeys_gravity, smooth_movement, auto_facing)
	
	# Set the initial animation to play
	_change_animation(_ANIMATION.IDLE)
	
# Runs every physics engine update
func _physics_process(delta) -> void:
	# Update cooldown timers
	if _attack_cooldown_timer < attack_cooldown:
		_attack_cooldown_timer += delta
	if _wait_cooldown_timer < _wait_cooldown:
		_wait_cooldown_timer += delta

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#

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

# Detects and sets the current state of the ai
func _detect_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int  = get_current_state()
	
	# Order for checking state. If a state is detected, then don't continue checking
	# for the next state:
	# Check for attacks
	# Check for movements (if not attacking)
	# Check for jump      (if movement is happening)
	# Check for waiting   (if movement is happening and jump is not happening)
	
	state_detected = _detect_attack_state()
	
	# If the current state isn't one fo the attacking states, then determine other possible states
	if state_detected != STATE.ATTACKING1 and state_detected != STATE.ATTACKING2 and state_detected != STATE.ATTACKING3 and state_detected != STATE.ATTACKING4 and state_detected != STATE.ATTACKING5 and state_detected != STATE.ATTACKING6:
		# Detect what movement state should be set
		state_detected = _detect_movement_state()
		# If returns a jumping state, then state_detected will change from the movement state
		state_detected = _detect_jumping_state()
		
		# If not jumping, then detect whether a wait should occur
		if state_detected != STATE.JUMPING:
			state_detected = _detect_waiting_state()
			
	return state_detected		

# Returns an attack state if criteria is met. Otherwise returns the current state of the ai.
func _detect_attack_state() -> int:
	# Holds the height of the collision shape of the player
	var player_height:  float = Globals.player.get_node("CollisionShape2D").get_shape().extents.y
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int  = get_current_state()
	
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
		if get_current_direction().x == DIRECTION.LEFT.x:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING1
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING1
			# If player is within horizontal range and is above/below in vertical range
			elif global_position.y - Globals.player_position.y <= player_height * 3 and global_position.x - Globals.player_position.x >= player_height:
				state_detected = STATE.ATTACKING3
			elif global_position.y - Globals.player_position.y >= -player_height * 3 and global_position.x - Globals.player_position.x <= -player_height:
				state_detected = STATE.ATTACKING5
			
		# If ai is facing right or is not currently moving
		else:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING2
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING2
			# If player is within horizontal range and is above/below in vertical range
			elif global_position.y - Globals.player_position.y <= player_height * 3 and global_position.x - Globals.player_position.x >= player_height:
				state_detected = STATE.ATTACKING6
			elif global_position.y - Globals.player_position.y >= -player_height * 3 and global_position.x - Globals.player_position.x <= -player_height:
				state_detected = STATE.ATTACKING4
			
	# If player is to the left of the ai
	elif global_position.x - Globals.player_position.x >= -standard_distance_from_player and global_position.x - Globals.player_position.x <= 0:
		# If ai is facing left
		if get_current_direction().x == DIRECTION.LEFT.x:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING2
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING2
			# If player is within horizontal range and is above/below in vertical range
			elif global_position.y - Globals.player_position.y <= player_height * 3 and global_position.x - Globals.player_position.x >= player_height:
				state_detected = STATE.ATTACKING6
			elif global_position.y - Globals.player_position.y >= -player_height * 3 and global_position.x - Globals.player_position.x <= -player_height:
				state_detected = STATE.ATTACKING4
			
		# If ai is facing right or is not currently moving
		else:
			# If player is within attacking range vertically
			if global_position.y - Globals.player_position.y <= player_height and global_position.y - Globals.player_position.y >= 0:
				state_detected = STATE.ATTACKING1
			elif global_position.y - Globals.player_position.y >= -player_height and global_position.y - Globals.player_position.y <= 0:
				state_detected = STATE.ATTACKING1
			# If player is within horizontal range and is above/below in vertical range
			elif global_position.y - Globals.player_position.y <= player_height * 3 and global_position.x - Globals.player_position.x >= player_height:
				state_detected = STATE.ATTACKING5
			elif global_position.y - Globals.player_position.y >= -player_height * 3 and global_position.x - Globals.player_position.x <= -player_height:
				state_detected = STATE.ATTACKING3
			
	print(state_detected)
	
	return state_detected
	
# Returns a movement state based on location and current state of the ai
func _detect_movement_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int  = get_current_state()
	
	# Custom key:
	# MOVING1:  moving left
	# MOVING2:  moving right
	# WAITING1: waiting next to a wall
			
	# Check for a condition that would cause movement direction to change
	if is_on_wall():
		# If currently moving to the right
		if get_current_velocity().x > 0:
			state_detected = STATE.MOVING2
		# If currently moving to the left or not moving, move left
		else:
			state_detected = STATE.MOVING1
	# If not moving in any direction, pick a random direction
	elif state_detected != STATE.MOVING1 and state_detected != STATE.MOVING2:
		_rng.randomize()
		if _rng.randi_range(0, 1):
			state_detected = STATE.MOVING1
		else:
			state_detected = STATE.MOVING2
			
	return state_detected

# Returns the jumping state if criteria is met. Otherwise returns the current state of the ai.
func _detect_jumping_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int  = get_current_state()
	
	# Check if within scaffolding 
	if !_decided_jump and _scaffolding_id != 0 and _scaffolding_id != 2:
		# Randomly decide to jump or not jump
		_rng.randomize()
		# 1 in 8 chance of jumping
		if !(_rng.randi_range(0, 7)):
			state_detected = STATE.JUMPING
			
		_decided_jump  = true
			
	return state_detected

# Returns the waiting state if criteria is met. Otherwise returns the current state of the ai.
func _detect_waiting_state() -> int:
	# Used to determine if the current state of the ai has been detected or not
	var state_detected: int  = get_current_state()
	
	# Custom key:
	# WAITING1: wait
	
	# If the current state is one of the movement states, then randomly decide to wait or not
	if get_current_state() == STATE.MOVING1 or get_current_state() == STATE.MOVING2 or get_current_state() == STATE.MOVING3 or get_current_state() == STATE.MOVING4 or get_current_state() == STATE.MOVING5 or get_current_state() == STATE.MOVING6:
		_rng.randomize()
		
		# Only randomly decide to wait if the cooldown is past
		if _wait_cooldown_timer >= _wait_cooldown:
			# 1 in 5 chance for the ai to wait
			if _rng.randi_range(0, 4):
				state_detected = STATE.WAITING1
				
			# Regardless of decision, reset the cooldown timer
			_wait_cooldown_timer = 0.0
	
	return state_detected
	
# Detects and (if needed) changes the current stage of the ai
func _detect_stage() -> void:
	pass
	
	
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
	# Temporarily holds the current state of the ai (so that get_current_state()
	# doesn't need to be called over and over)
	var current_state = get_current_state()
	
	# Enable movement
	#set_movement_enabled(true)
	
	# Set the current state to the state returned by _detect_state
	current_state = _detect_state()
	set_current_state(current_state)
	
	print(current_state)
	
	# Perform actions depending upon the current state
	match current_state:
		STATE.ATTACKING1: # ATTACKING1: player is directly in front of ai
			#attack()
			pass
		STATE.ATTACKING2: # ATTACKING2: player is directly behind ai
			pass
		STATE.ATTACKING3: # ATTACKING3: player is in front and above of ai
			pass
		STATE.ATTACKING4: # ATTACKING4: player is behind and above ai
			pass
		STATE.ATTACKING5: # ATTACKING5: player is in front and below ai
			pass
		STATE.ATTACKING6: # ATTACKING6: player is behind and below ai
			pass
		STATE.MOVING1: # MOVING1:  moving left
			#move_dynamically(DIRECTION.LEFT)
			pass
		STATE.MOVING2: # MOVING2:  moving right
			#move_dynamically(DIRECTION.RIGHT)
			pass
		STATE.MOVING3:
			pass
		STATE.MOVING4:
			pass
		STATE.MOVING5:
			pass
		STATE.MOVING6:
			pass
		STATE.JUMPING:
			pass
		STATE.WAITING1:
			pass
		_:
			pass

# Code for the ai run during stage two of the fight
func _run_ai_stage_two() -> void:
	pass

# Code for the ai run during stage three of the fight
func _run_ai_stage_three() -> void:
	pass

# Code for the ai run during stage four of the fight
func _run_ai_stage_four() -> void:
	pass
	
# Code called when the boss fight is finished
func _finish_fight() -> void:
	pass
	


#-----------------------------------------------------------------------------#
#                                Signal Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# Signals that must be setup
#=============================
# Set initial values for use in boss ai here
func _on_zorro_boss_init() -> void:
	set_current_ai_stage(STAGE.ONE)
	set_movement_direction(DIRECTION.LEFT)

# Custom code for when the zorro boss attacks
# Change animations, set movement, etc
func _on_zorro_boss_attacked() -> void:
	if _attack_cooldown_timer >= attack_cooldown:
		# Pause the ai so physics_process doesn't trigger the current stage ai to run again
		pause_ai()
		
		# Play attack animation and wait until it is complete
		_change_animation(_ANIMATION.ATTACK)
		yield($AnimationPlayer, "animation_finished")
		
		# Note: the dash() function is called in the AnimationPlayer for the attack animation
		
		# Pause the ai with an idle animation for a bit
		_change_animation(_ANIMATION.IDLE)
		set_movement_enabled(false)
		_timer.start(1.0)
		yield(_timer, "timeout")
		
		# Now that the wait is done, unpause the ai
		resume_ai()
	
		# Reset the attack cooldown
		_attack_cooldown_timer = 0.0

# This signal is sent whenever any stage is run
func _on_zorro_boss_stage_ran(stage_number):
	# If the current stage running is not STAGE.NONE then check statistics
	if stage_number != STAGE.NONE:
		_check_within_scaffolding()
	
	# Pause ai.gd until ai code in this script is complete
	pause_ai()

	# Run ai depending upon the stage
	match stage_number:
		STAGE.ONE:
			_run_ai_stage_one()
		STAGE.TWO:
			_run_ai_stage_two()
		STAGE.THREE:
			_run_ai_stage_three()
		STAGE.FOUR:
			_run_ai_stage_four()
		STAGE.FINISHED:
			_finish_fight()
		_:
			pass
			
	resume_ai()

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
	pass # Replace with function body.

# Emitted when the ai is resumed (after a pause)
func _on_zorro_boss_ai_resumed():
	pass # Replace with function body.

# Emitted after an ai_stage is made
func _on_zorro_boss_stage_changed(previous_stage, new_stage):
	pass # Replace with function body.

# Emitted after the ai turns aound either through turn_around() or set_movement_direcion()
func _on_zorro_boss_turned_around(h_new_direction):
	# Flip all dr. geary sprites
	for child in get_node("sprites").get_children():
		if child is Sprite:
			child.scale.x *= -1
				
	# Flip the sword sprite and collision shape
	$sword.scale.x *= -1

#=============================
# Signals not from ai.gd
#=============================
# Note that player damage is already taken care of using entity.gd
# This signal is meant for puroses other than damage detection
func _on_zorro_boss_collision(body) -> void:
	pass # Replace with function body.
