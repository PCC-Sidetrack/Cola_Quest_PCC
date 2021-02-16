#-----------------------------------------------------------------------------#
# Class Name:   zorro_ai.gd
# Description:  AI for the zorro boss entity in the rooftop level
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: February 15, 2021
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
export var speed:           float = 4.0

# Damage that zorro deals to entitys
export var damage:          int   = 1
# Max health of boss
export var max_health:      int   = 16

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Holds the current stage of the boss fight
var _current_ai_stage:       int
# Holds hp level that triggers stage two
var _stage_two_trigger:      int = 11
# Holds hp level that triggers stage three
var _stage_three_trigger:    int = 6
# Holds the hp level that triggers the end of the boss fight
var _stage_finished_trigger: int = 1
# Tracks the number of stage change triggers that have occured so that the triggers
# can only occur once
var _stage_change_triggers:  int = 0

# Holds the current animation being shown
var _current_animation: String = _ANIMATION.IDLE
# Holds the name of the current sprite being used in an animation
var _current_sprite:    String = ""

# Tracks whether the ai is currently doing an action that shouldn't be interupted
var _uninterrupted_action: bool = false
# Tracks whether the sprite is currently flipped
var _sprite_flipped:       bool = false
# Boolean tracking if the boss should be moving in its current direction or not.
# If the boolean is set to true, the boss will move in _current_direction at the end
# of the physics process.
var _boss_should_move:     bool = false

# Holds a Timer that can be used throughout the class
var _timer: Timer = Timer.new()

# Holds the current movement direction in a vector. 
# This is automatically taken care of.
var _current_direction: Vector2



#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#



#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
func _ready() -> void:
	# Initialze class variables
	_current_direction = _DIRECTION.LEFT
	_current_ai_stage  = _AI_STAGE.STAGE_ONE
	
	# Initialize the boss
	initialize_enemy(max_health, damage, speed, acceleration, jump_speed, obeys_gravity, smooth_movement)
	set_auto_facing(false)
	
	# Set the initial animation to play
	_change_animation(_ANIMATION.IDLE)
	
	# Setup the timer
	add_child(_timer)
	_timer.set_one_shot(true)
	
func _physics_process(delta) -> void:
	# Set the boss to not currently moving (if desired, this is changed ai stage code during the physics process)
	_boss_should_move = false
	
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
		# Flip the boss sprites if needed
		if !get_auto_facing():
			if _current_direction.x == _DIRECTION.RIGHT.x && _sprite_flipped:
				_flip()
			elif _current_direction.x == _DIRECTION.LEFT.x && !_sprite_flipped:
				_flip()
				
		
		
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
				
		# Move whatever the current velocity of the boss is
		if _boss_should_move:
			move_dynamically(_current_direction)
		else:
			move_dynamically(Vector2(0.0, 0.0))


#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# AI Actions
#
# Note: No movement will occur when an action is called unless the method calling
# the action sets the _boss_should_move boolean to true. It gets reset back to
# false at the beginning of this script's physics process loop.
#=============================

# Attack action
func attack(uninterruptable_action: bool) -> void:
	# Let the ai know that an uninterruptable action is occuring
	if uninterruptable_action:
		_uninterrupted_action = true
		
	# Let the ai know that the uninterruptable action is complete
	_uninterrupted_action = false
	
# Sets the direction facing to the opposite of it's current direction
func turn_around() -> void:
	_current_direction.x *= -1
	
	# Move slightly in the direction now facing to make sure the boss is
	# away from the wall and doesn't start a loop of turning around
	#global_position.x += sign(_current_direction.x) * 50.0

# Moves the boss by instantly in the direction it's currently facing (left or right)
# Sets the velocity based on the boss's movement speed
# The boss will slow down over time back to no movement unless movement is updated
#func move_boss_instantly_h():
#	if _current_direction.x == _DIRECTION.RIGHT.x:
#		_current_direction.x = _DIRECTION.RIGHT.x
#	else:
#		_current_direction.x = _DIRECTION.LEFT.x
	
# Moves at the boss's movement speed until the boss has gone past the x value given
func move_boss_to_x(x: float):
	pass

# Moves at the boss's movement speed until the boss has gone past the y value given
func move_boss_to_y(y: float):
	pass

#=============================
# Getters
#=============================
func get_current_animation() -> String:  return _current_animation
func get_current_ai_stage()  -> int:     return _current_ai_stage

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

# Change the animation of the sprite giving a string from the _ANIMATION dictionary.
func _change_animation(animation: String) -> void:
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
			if sprite.visible == true:
				sprite.visible = false
				
		# Set the correct sprite to visible and play the animation
		$sprites.get_node(_current_sprite).visible = true
		$AnimationPlayer.play(_current_animation)
			
	else:	
		ProgramAlerts.add_warning("In boss fight AI, attempted to change an animation to non-existant animation id.")

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

# Sets a boolean and cycles a thread until the given time (in seconds) is finished
func _uninterrupted_wait(seconds: float) -> void:
	_uninterrupted_action = true
	_timer.start(seconds)
	yield(_timer, "timeout")
	_uninterrupted_action = false
	
		
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
	_boss_should_move = true
	
	if is_on_wall():
		turn_around()
		
	pass
	
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
		
# Triggered when boss dies
func _on_zorro_boss_death():
	pass

# Triggered when boss has a change in health
func _on_zorro_boss_health_changed(ammount):
	pass

# Triggered when the object this script is attached to is being removed from the game
func _on_tree_exiting():
	_timer.free()


