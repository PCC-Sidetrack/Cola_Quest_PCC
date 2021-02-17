#-----------------------------------------------------------------------------#
# Class Name:   zorro_ai.gd
# Description:  Advanced ai script for bosses
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 16, 2021
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                              Private Constants                              #
#-----------------------------------------------------------------------------#
# Enums for animations
const _ANIMATION: Dictionary = {
	IDLE          = "idle_sword",
	IDLE_NO_SWORD = "idle_no_sword",
	ARM_WAVE      = "arm_wave",
	DRAW_SWORD    = "draw_sword",
	SHEATH_SWORD  = "sheath_sword",
	JUMP          = "jump_sword",
	JUMP_NO_SWORD = "jump_no_sword",
	ATTACK        = "sword_attack",
	THROW         = "throw",
	WALK          = "walk_sword",
	WALK_NO_SWORD = "walk_no_sword"
}

# Enums to hold the current boss fight stage
const _AI_STAGE: Dictionary = {
	NONE        = 0,
	STAGE_ONE   = 1,
	STAGE_TWO   = 2,
	STAGE_THREE = 3
}

# Enums for direction
const _DIRECTION: Dictionary = {
	NONE       = Vector2(0.0, 0.0),
	RIGHT      = Vector2(1.0, 0.0),
	LEFT       = Vector2(-1.0, 0.0),
	UP         = Vector2(0.0, 1.0),
	DOWN       = Vector2(0.0, -1.0),
	RIGHT_UP   = Vector2(1.0, 1.0),
	RIGHT_DOWN = Vector2(1.0, -1.0),
	LEFT_UP    = Vector2(-1.0, 1.0),
	LEFT_DOWN  = Vector2(-1.0, -1.0)
}


#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#

# Controls whether zorro obeys gravity
export var obeys_gravity:   bool  = true
# Controls whether zorro accelerates into movement or not
export var smooth_movement: bool  = true

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
#                              Public Constants                               #
#-----------------------------------------------------------------------------#
# Enums for current AI state
const STATE: Dictionary = {
	NONE      = -1,
	MOVING1   = 0,
	MOVING2   = 1,
	MOVING3   = 2,
	JUMPING   = 3,
	ATTACKING = 4,
	WAITING   = 5
}

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Holds the current stage of the boss fight
var _current_ai_stage:       int = _AI_STAGE.STAGE_ONE
# Holds hp level that triggers stage two
var _stage_two_trigger:      int = 11
# Holds hp level that triggers stage three
var _stage_three_trigger:    int = 6
# Holds the hp level that triggers the end of the boss fight
var _stage_finished_trigger: int = 1
# Tracks the number of stage change triggers that have occured so that the triggers
# can only occur once
var _stage_change_triggers:  int = 0
# Current state of the ai
var _current_state:          int = STATE.NONE

# Tracks the cooldown for attacking
var _attack_cooldown_timer: float = 0.0
# Tracks the cooldown for dashing
var _dash_cooldown_timer:   float = 0.0

# Holds the current animation being shown
var _current_animation: String = _ANIMATION.IDLE
# Holds the name of the current sprite being used in an animation
var _current_sprite:    String = ""

# Tracks whether the ai is currently doing an action that shouldn't be interupted
var _uninterrupted_action: bool = false
# Tracks whether the sprite is currently flipped
var _sprite_flipped:       bool = false
# Indicates if a last direction is currently saved and shouldn't be updated
var _is_direction_saved:   bool = false

# Holds a Timer that can be used throughout the class
var _timer: Timer = Timer.new()

# Holds the current movement direction in a vector. 
# This is automatically taken care of.
var _current_direction: Vector2
# Holds the last recorded _current_direction. Should only be edited
# through set_last_direction and get_last_direction
var _last_direction: Vector2



#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
func _ready() -> void:
	# Initialze class variables
	_current_direction = _DIRECTION.LEFT
	_last_direction    = _current_direction
	
	# Initialize the boss
	initialize_enemy(max_health, damage, speed, acceleration, jump_speed, obeys_gravity, smooth_movement)
	set_auto_facing(false)
	
	# Set the initial animation to play
	change_animation(_ANIMATION.WALK)
	
	# Setup the timer
	add_child(_timer)
	_timer.set_one_shot(true)
	
func _physics_process(delta) -> void:
	# Update timers that rely on delta
	if _attack_cooldown_timer < attack_cooldown:
		_attack_cooldown_timer += delta
	if _dash_cooldown_timer < dash_cooldown:
		_dash_cooldown_timer += delta
		
	# Flip the boss sprites if needed
	if !get_auto_facing():
		if _current_direction.x == _DIRECTION.RIGHT.x and _sprite_flipped:
			_flip()
		elif _current_direction.x == _DIRECTION.LEFT.x and !_sprite_flipped:
			_flip()
	
	# Set the current stage of the boss fight if needed
	# If a stage has changed, call the method for the corresponding stage change
	match _current_ai_stage:
		_AI_STAGE.STAGE_ONE:
			if get_current_health() <= _stage_two_trigger:
				_on_change_to_stage_two()
				if _stage_change_triggers <= 0:
					_current_ai_stage = _AI_STAGE.STAGE_TWO
					_stage_change_triggers = 1
		_AI_STAGE.STAGE_TWO:
			if get_current_health() <= _stage_three_trigger:
				_on_change_to_stage_three()
				if _stage_change_triggers <= 1:
					_current_ai_stage = _AI_STAGE.STAGE_THREE
					_stage_change_triggers = 2
			elif get_current_health() > _stage_two_trigger:
				_current_ai_stage = _AI_STAGE.STAGE_ONE
		_AI_STAGE.STAGE_THREE:
			if get_current_health() <= _stage_finished_trigger:
				_on_change_to_fight_finished()
				if _stage_change_triggers <= 2:
					_current_ai_stage = _AI_STAGE.NONE
					_stage_change_triggers = 3
			elif get_current_health() > _stage_three_trigger:
				_current_ai_stage = _AI_STAGE.STAGE_TWO
		_:
			pass
			
	

	# If the ai is not doing an uninterruptable action, then perform the boss ai
	if !_uninterrupted_action:
		# Perform the tasks in the current ai stage
		match _current_ai_stage:
			_AI_STAGE.STAGE_ONE:
				_run_ai_stage_one()
			_AI_STAGE.STAGE_TWO:
				_run_ai_stage_two()
			_AI_STAGE.STAGE_THREE:
				_run_ai_stage_three()
			_:
				_run_ai_none()


#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
# Change the animation of the sprite giving a string from the _ANIMATION dictionary.
func change_animation(animation: String) -> void:
	# Only perform a change if the animation given isn't already running
	if animation != _current_animation:
		# Make sure the integer given is in the dictionary. If not, give a warning.
		if animation in _ANIMATION.values():
			_current_animation = animation
			
			# Determine the current sprite to show
			match animation:
				_ANIMATION.IDLE:
					_current_sprite = "idle"
				_ANIMATION.IDLE_NO_SWORD:
					_current_sprite = "idle"
				_ANIMATION.ARM_WAVE:
					_current_sprite = "arm_wave"
				_ANIMATION.DRAW_SWORD:
					_current_sprite = "draw_sword"
				_ANIMATION.SHEATH_SWORD:
					_current_sprite = "draw_sword"
				_ANIMATION.JUMP:
					_current_sprite = "jump"
				_ANIMATION.JUMP_NO_SWORD:
					_current_sprite = "jump"
				_ANIMATION.ATTACK:
					_current_sprite = "sword_attack"
				_ANIMATION.THROW:
					_current_sprite = "throw"
				_ANIMATION.WALK:
					_current_sprite = "walk"
				_ANIMATION.WALK_NO_SWORD:
					_current_sprite = "walk"
				_:
					ProgramAlerts.add_error("In boss fight AI, animation given has no sprite name assigned to it.")
				
			# First set all the sprites to invisible
			for sprite in $sprites.get_children():
				sprite.visible = false
					
			# Set the correct sprite to visible and play the animation
			$sprites.get_node(_current_sprite).visible = true
			$AnimationPlayer.stop()
			$AnimationPlayer.play(_current_animation)
			
		else:	
			ProgramAlerts.add_warning("In boss fight AI, attempted to change an animation to non-existant animation id.")

# Locks the saving of the last direction. Calling save_last_direction() doesn't work
# when this is locked.
func lock_last_saved_direction() -> void:
	_is_direction_saved = true

# Unlocks the saving of the last direction. Calling save_last_direction() doesn't work
# when this is locked.
func unlock_last_saved_direction() -> void:
	_is_direction_saved = true
	
# Returns whether the changing the last direction is locked or not
func is_save_last_direction_locked() -> bool:
	return _is_direction_saved
	
# Note: the _last_direction is only saved if _is_direction_saved is false
# Calling this method will set _is_direction_saved to true, so it must be unlocked
# After done using the _last_direction variable (after calling get_last_saved_direction())
# To do this, call the method unlock_last_direction
func save_last_direction() -> void:
	if !_is_direction_saved:
		lock_last_saved_direction()
		_last_direction = _current_direction

#=============================
# AI Actions
#=============================

# Attack action
# TESTED: WORKING
func attack(uninterruptable_action: bool = true) -> void:
	# Before executing any atacking code, check that the attack cooldown is
	# not in progress
	if _attack_cooldown_timer >= attack_cooldown:
		# Set the current state of the AI
		_current_state = STATE.ATTACKING
			
		# Let the ai know that an uninterruptable action is occuring
		if uninterruptable_action:
			_uninterrupted_action = true
		
		#=============================	
		# Attack Code
		#=============================
		
		# For this action, movement should be enabled (for dash()), but the boss should stop moving
		# before performing the action
		save_last_direction()
		_current_direction = _DIRECTION.NONE
		
		# Play attack animation
		change_animation(_ANIMATION.ATTACK)
		print("here")
		# Note: the dash() function is called in the AnimationPlayer for the attack animation
		
		# Wait until the attack animation is complete
		yield($AnimationPlayer, "animation_finished")
		
		change_animation(_ANIMATION.IDLE)
		_timer.start(1.0)
		yield(_timer, "timeout")
		
		# Set the current direction (indicating movement) back to what it was before attacking
		_current_direction = get_last_direction()
		unlock_last_saved_direction()
		
		#=============================
		# End of Attack Code
		#=============================
		
		# Reset the attack cooldown timer
		_attack_cooldown_timer = 0.0
		
		# Let the ai know that the uninterruptable action is complete
		_uninterrupted_action = false
	
# Sets the direction facing to the opposite of it's current direction
# TESTED: WORKING
func turn_around() -> void:
	_current_direction.x *= -1
	
# Move in the given direction
# The given direction is a vector of any values. Doesn't have to be contained in the _DIRECTION dictionary
func move_in_direction(direction: Vector2, uninterruptable_action: bool = false) -> void:
	# Set the current state of the AI
	_current_state = STATE.MOVING1
	
	# Let the ai know that an uninterruptable action is occuring
	if uninterruptable_action:
		_uninterrupted_action = true
	
	move_dynamically(direction)
	
	# Let the ai know that the uninterruptable action is complete
	_uninterrupted_action = false
	
# Moves at the boss's movement speed until the boss has gone past the x value given
# Returns true if the boss has reached/passed the point
# TESTED: WORKING
func move_towards_x(x: float, uninterruptable_action: bool = false) -> bool:
	# Saves the direction (left or right) that the boss needs to go to get to the 
	# point given
	var direction_to_point: Vector2
	# Once calculated, indicates if the boss has moved past the point x
	var moved_past_x:       bool = false
	
	# Set the current state of the AI
	_current_state = STATE.MOVING2
	
	# Let the ai know that an uninterruptable action is occuring
	if uninterruptable_action:
		_uninterrupted_action = true
		
	# Movement Code
	if global_position.x - x > 0:
		_current_direction.x = _DIRECTION.LEFT.x
		direction_to_point   = _DIRECTION.LEFT
	elif global_position.x - x < 0:
		_current_direction.x = _DIRECTION.RIGHT.x
		direction_to_point   = _DIRECTION.RIGHT
	
	# Let the ai know that the uninterruptable action is complete
	_uninterrupted_action = false
	
	move_dynamically(_current_direction)
	
	# Check if the boss has moved past the x point given
	if direction_to_point == _DIRECTION.LEFT:
		if global_position.x - x <= 0:
			moved_past_x = true
	elif direction_to_point == _DIRECTION.RIGHT:
		if global_position.x - x >= 0:
			moved_past_x = true
	
	return moved_past_x
	

# Moves at the boss's movement speed until the boss has gone past the y value given
func move_towards_y(y: float, uninterruptable_action: bool = true) -> void:
	# Set the current state of the AI
	_current_state = STATE.MOVING2
	
	# Let the ai know that an uninterruptable action is occuring
	if uninterruptable_action:
		_uninterrupted_action = true
	
	# Movement Code
	
	# Let the ai know that the uninterruptable action is complete
	_uninterrupted_action = false
	
	move_dynamically(_current_direction)
	
# Causes the boss to dash forward based on speed multiplier given
# TESTED: WORKING
func dash(speed_multiplier: float = dash_multiplier) -> void:
	if _dash_cooldown_timer >= dash_cooldown:
		# Set the current state of the AI
		_current_state = STATE.MOVING3
	
		set_velocity(Vector2(get_last_direction().x * get_speed() * speed_multiplier, get_current_velocity().y))
		move_dynamically(_current_direction)
		
# Sets a boolean and cycles a thread until the given time (in seconds) is finished.
# Does not allowing physics process to call AI methods
# TESTED: WORKING
func uninterrupted_wait(seconds: float, stop_moving: bool = true) -> void:
		# Set the current state of the AI
		_current_state = STATE.WAITING
	
		_uninterrupted_action = true
		
		# If desired, save the last direction and stop movement
		if stop_moving:
			save_last_direction() # Also locks the ability to save the last direction
			_current_direction = _DIRECTION.NONE
		
		_timer.start(seconds)
		yield(_timer, "timeout")
		
		# If movement was stopped, then reset it back to the last
		# movement direction and unlock the ability to save the
		# last direction again.
		if stop_moving:
			_current_direction = get_last_saved_direction()
			unlock_last_saved_direction()

		_uninterrupted_action = false

#=============================
# Getters
#=============================
func get_current_animation()    -> String:  return _current_animation
func get_current_ai_stage()     -> int:     return _current_ai_stage
func get_current_state()        -> int:     return _current_state
func get_last_saved_direction() -> Vector2: return _last_direction

#=============================
# Setters
#=============================
func set_current_animation(animation: String) -> void:
	if animation in _ANIMATION.values():
		_current_animation = animation
	else:
		_current_animation = _ANIMATION.IDLE

func set_current_ai_stage(id: int) -> void:
	if id in _AI_STAGE.values():
		_current_ai_stage = id
	else:
		_current_ai_stage = _AI_STAGE.NONE

#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#
# Custom code for flipping the boss. Use if the automatic flipping code doesn't cut it.
func _flip() -> void:
	# Flip all dr. geary sprites
	for child in get_node("sprites").get_children():
		if child is Sprite:
			child.scale.x *= -1
				
	# Flip the sword sprite and collision shape
	$sword.scale.x *= -1

	# Remember that the sprite is flipped to the right
	_sprite_flipped = !_sprite_flipped
	
		
#=============================
# Actions taken upon a fight stage change (activated in _update_statistics)
#=============================

# Occurs when stage two is triggered
func _on_change_to_stage_two() -> void:
	pass
	
# Occurs when stage three is triggered
func _on_change_to_stage_three() -> void:
	pass
	
# Occurs when the fight is finished
func _on_change_to_fight_finished() -> void:
	pass
	
#=============================
# AI for Various Fight Stages
#=============================

# No AI
func _run_ai_none() -> void:
	pass

# Stage one AI
func _run_ai_stage_one() -> void:
	# STAGE ONE INSTRUCTIONS:
	# Move left and right (bouncing off the wall) until near the player's x value
	# If player's y value is within a range of enemy's own y value, then perform
	# a sword attack.
	# If not, check if inside a scaffolding area. If inside scaffolding area, jump up
	# and check again at the top of the jump for the x and y locations. Repeat top steps
	# until close to the player. When y value and x value are close to the player, make
	# a sword attack.
	
	# Check to see if boss is within attack range
	if global_position.x - Globals.player_position.x <= standard_distance_from_player and global_position.x - Globals.player_position.x >= 0:
		if _current_direction.x == _DIRECTION.LEFT.x or _current_direction.x == _DIRECTION.NONE.x:
			if abs(global_position.y - Globals.player_position.y) <= Globals.player.get_collision_box_size().y / 2:
				attack()
	elif global_position.x - Globals.player_position.x >= -standard_distance_from_player and global_position.x - Globals.player_position.x <= 0:
		if _current_direction.x == _DIRECTION.RIGHT.x or _current_direction.x == _DIRECTION.NONE.x:
			if abs(global_position.y - Globals.player_position.y) <= Globals.player.get_collision_box_size().y / 2:
				attack()
			
	# Set the animation for movement
	change_animation(_ANIMATION.WALK)
	
	#if _current_state == STATE.MOVING2 or _current_state == STATE.NONE:
	#	if move_towards_x(get_node("../../points/point1").get_position().x):
	#		_current_state = STATE.MOVING1
	#else:
	#	move_in_direction(_current_direction)
		
	move_in_direction(_current_direction)
		
	# If on a wall, switch the state to moving1
	if is_on_wall():
		turn_around()
		
		
	
	
	
# Stage two AI
func _run_ai_stage_two() -> void:
	# STAGE TWO INSTRUCTIONS:
	# Steal some of the player's hp (one hit point which will translate to 3 for him)
	# Spawn in some moving drones to make the parkour more difficult for the player.
	# Move left and right trying to avoid the player, stopping every once in a while
	# to play the taunting animation.
	# If in a place to jump on the scaffolding, then make a random decision to do so
	# or not.
	# Stop every once in a while and throw a 3x5 card at the player.
	pass
	
# Stage three AI
func _run_ai_stage_three() -> void:
	# STAGE THREE INSTRUCTIONS:
	# If drone's aren't still there, respawn them. Also spawn in a few 3x5 shooting
	# drones.
	# Combine the ai from stages one and two so that Dr. Geary is trying to 
	# attack with the sword and occasionally throw's 3x5 cards as well.
	pass
	

#-----------------------------------------------------------------------------#
#                                Trigger Methods                              #
#-----------------------------------------------------------------------------#
# Triggered when boss runs into something
func _on_Area2D_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		deal_damage(body)
		body.knockback(self)
		
		# Pause the boss for a second to allow the player time to regain themselves
		change_animation(_ANIMATION.IDLE)
		uninterrupted_wait(1.0)
		change_animation(_ANIMATION.WALK)
		
# Triggered when boss dies
func _on_zorro_boss_death():
	pass

# Triggered when boss has a change in health
func _on_zorro_boss_health_changed(amount):
	pass

# Triggered when the object this script is attached to is being removed from the game
func _on_tree_exiting():
	_timer.free()

# Triggered when the boss's sword hits something
func _on_sword_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER) and body is Entity:
		change_animation(_ANIMATION.IDLE)
		uninterrupted_wait(1.0)
		change_animation(_ANIMATION.WALK)
