#-----------------------------------------------------------------------------#
# Class Name:   ai.gd
# Description:  Holds functions that allow ai to be easily implemented by
#               any inheriting
# Author:       Andrew C. Zedwick
# Company:      Sidetrack
# Last Updated: 2/17/2021
#-----------------------------------------------------------------------------#

class_name AI
extends    Entity

#-----------------------------------------------------------------------------#
# Basic Use of this Class
# This class is meant to be inherited by an ai script.
# What this class provides:
#    - A timing framework for various actions for an ai.
#    - Initialization of the ai entity. initialization() must be called in the _ready()
#      method of the inheriting script.
#    - Several basic actions that can be utilized by the ai: attack(), turn_around(),
#      dash(multiplier), pause_ai(seconds), and resume_ai()
#    - Movement: Handled by jump(multiplier), get_movement_direction(), set_movement_direction(),
#                is_currently_moving(), get_movement_enabled(), and set_movement_enabled()
#                Use these methods to control when and where the entiy is moving.
#                Movement occurs automatically every physics process.
#    - AI:       AI is handled through custom stage triggers. Use the STAGE
#                dictionary to call set_current_ai_stage(). A function for each
#                stage is called depending upon th current stage. Signals are
#                used to create your custom stage.
#                get_current_ai_stage() allows you to detect when the ai is in
#                a current stage. A signal is emitted with the last and new stage
#                when a stage change occurs.
#   - Class Setup Notes:
#                * If you initialize() the ai without autofacing then the flip signal
#                  needs to be used to add custom code for flipping the entity.
#                * An initial stage needs to be selected (set as NONE at first)
#                  and code using the run_stage_# signal should be written to control
#                  what happens at any given stage.
#                * Stage changes don't happen automatically, code needs to be written
#                  to trigger the change.
#                * Animations don't happen automatically. It's recommended to setup
#                  a dictinary with an animation title connected to an array with
#                  the animation name and the sprite name to be made visible. For
#                  an example, look at the the ai_ai.gd code.
#                * Changing animations isn't handled here. That allows you to setup
#                  your sprite nodes however you wish. For an example of how animation
#                  changes can be done, look at the ai_ai.gd code.
#                * Turning around should not be done by using set_movement_direction()
#                * set_movement_enbled() is set to false every physics process so long as
#                  the ai is not currently paused throug pause_ai(). To have the ai move in
#                  the current direction, set_movement_enabled(true) must be called first in
#                  the run_stage_# signal method (in the inheriting script)
#   - Signals:   Directly below are all of the signals that can be connected to
#                this class. The class handles the timing for when these signals
#                occur while allowing you to put custom code into them.
#                Read the comments above each signal to see when they are emitted.
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                         Custom Signal Declarations                          #
#-----------------------------------------------------------------------------#
# Signal is sent after the initialize() method is called. initialize() must be
# called in _ready() function of inheriting script.
signal init()
# Signal is sent whenever the direction being moved in is changed and allows
# inheriting classes to create custom code for flipping an entity. h_direction_facing
# will be either DIRECTION.LEFT or DIRECTION.RIGHT
signal fliped(h_direction_facing)
# Signal is sent whenever a change in the stage of the ai is made through set_current_ai_stage()
signal stage_changed(previous_stage, new_stage)
# Signal emitted when no ai stage is currently set (called by _physics_process)
signal run_no_stage()
# Signal emitted when a call to the stage one ai is made by _physics_process
signal run_stage_one()
# Signal emitted when a call to the stage two ai is made by _physics_process
signal run_stage_two()
# Signal emitted when a call to the stage three ai is made by _physics_process
signal run_stage_three()
# Signal emitted when a call to the stage four ai is made by _physics_process
signal run_stage_four()
# Signal emitted when the fight is ended ai is made by _physics_process
signal fight_ended()
# Signal emitted whenever the attack() method is called
signal attack()
# Signal emitted whenever the turn_around() method is called
signal turned_around()
# Signal emitted whenever a dash() is performed
signal dashed(multiplier)
# Signal emitted whenever the ai was just paused. Pausing the ai doesn't stop all
# functions of the ai (it's not static in other words) but it does prevent any
# of the ai stages from being activated for the given amount of time
signal ai_paused(num_seconds)
# Signal emitted whenever the ai is unpaused (either at the end of the pause_ai()
# mehtod or when the resume_ai() mehtod is called)
signal ai_resumed()

#-----------------------------------------------------------------------------#
#                               Public Constants                              #
#-----------------------------------------------------------------------------#
# Dictionary for direction
const DIRECTION: Dictionary = {
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

# Holds Dictionary for the current stage (between 1 through 3 and none)
const STAGE: Dictionary = {
	NONE     = 0,
	ONE      = 1,
	TWO      = 2,
	THREE    = 3,
	FOUR     = 4,
	FINISHED = 5
}

# Enums for current AI state
# This dictionary is meant to allow the class inheriting this class to track
# various states of the ai. The state is not updated in this class, but must be
# done by the inheriting class through the getter and setter methods.
const STATE: Dictionary = {
	NONE       = -1,
	MOVING1    = 0,
	MOVING2    = 1,
	MOVING3    = 2,
	JUMPING    = 3,
	ATTACKING1 = 4,
	ATTACKING2 = 5,
	ATTACKING3 = 6,
	WAITING    = 7,
	CUSTOM1    = 8,
	CUSTOM2    = 9,
	CUSTOM3    = 10
}

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#

#=============================
# Integers
#=============================

# Holds the current stage of the boss fight
var _current_ai_stage: int = STAGE.NONE
# Holds the current state of the boss fight
var _current_ai_state: int = STATE.NONE
# Damage that the ai deals to entities
var _ai_damage:        int = 1
# Max health of boss
var _max_health:       int = 16

#=============================
# Floats
#=============================

# Indicates the cooldown for attacking (in seconds)
var _attack_cooldown:       float = 1.0
# Indicates the cooldown for dashing (in seconds)
# Should be same as or less than attack cooldown if used in an attack action
var _dash_cooldown:         float = _attack_cooldown
# Tracks the cooldown for attacking
var _attack_cooldown_timer: float = 0.0
# Tracks the cooldown for dashing
var _dash_cooldown_timer:   float = 0.0
# Controls the acceleration of movement if smooth_movement is turned on
var _acceleration:          float = 20.0
# Speed at which the ai jumps
var _jump_speed:            float = 850.0
# Speed at which the ai moves
var _speed:                 float = 5.0
# Multiplier applied to speed for dashing
var _dash_multiplier:       float = 3.0


#=============================
# Booleans
#=============================

# Indicates if movement is currently enabled
var _movement_enabled:     bool = false
# Tracks whether the ai is currently doing an action that shouldn't be interrupted
var _uninterrupted_action: bool = false
# Tracks whether the sprite is currently flipped
var _sprite_flipped:       bool = false
# Tracks whether the ai is currently paused
var _ai_paused:            bool = false
# Controls whether the ai obeys gravity
var _obeys_gravity:        bool = true
# Controls whether the ai accelerates into movement or not
var _smooth_movement:      bool = true

#=============================
# Vectors
#=============================

# Holds the current movement direction in a vector. 
# This is automatically taken care of.
var _current_direction: Vector2

#=============================
# Miscellaneous
#=============================

# Holds a Timer that can be used throughout the class
var _timer: Timer = Timer.new()

#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialze class variables
	_current_direction = DIRECTION.NONE

	# Setup the timer
	add_child(_timer)
	_timer.set_one_shot(true)
	
# Runs every physics engine update
func _physics_process(delta) -> void:
	# Update timers that rely on delta
	if _attack_cooldown_timer < _attack_cooldown:
		_attack_cooldown_timer += delta
	if _dash_cooldown_timer < _dash_cooldown:
		_dash_cooldown_timer += delta
		
	# Flip the boss sprites if needed
	if !get_auto_facing():
		if _current_direction.x == DIRECTION.RIGHT.x and _sprite_flipped:
			_flip()
		elif _current_direction.x == DIRECTION.LEFT.x and !_sprite_flipped:
			_flip()
	

	# If the ai is not doing an uninterruptable action, then perform the boss ai
	if !_uninterrupted_action:
		# Disable movement before ai is called (allowing the ai to determine if movement should occur
		_movement_enabled = false
		
		# Perform the tasks in the current ai stage
		match _current_ai_stage:
			STAGE.ONE:
				emit_signal("run_stage_one")
			STAGE.TWO:
				emit_signal("run_stage_two")
			STAGE.THREE:
				emit_signal("run_stage_three")
			STAGE.FOUR:
				emit_signal("run_stage_four")
			STAGE.FINISHED:
				emit_signal("fight_ended")
			_:
				emit_signal("run_no_stage")

	# Update the boss movement, but update it towards no movement if movement isn't enabled
	# Note: this is done regardless of whether or not an uninteruptable action is occuring
	#       which enables an uninteruptable action to cause movement to or not to occur
	if _movement_enabled:
		move_dynamically(_current_direction)
	else:
		move_dynamically(Vector2(0.0, 0.0))
	

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# AI Actions
#=============================
# Attack action
func attack(uninterruptable: bool = true) -> void:
	# Before executing any atacking code, check that the attack cooldown is
	# not in progress
	if _attack_cooldown_timer >= _attack_cooldown:		
		# Let the ai know that an uninterruptable action is occuring
		if uninterruptable:
			_uninterrupted_action = true
		
		#=============================	
		# Attack Code
		#=============================
		
		# Emit a signal to allow custom code to occur before the action is finished
		emit_signal("attack")
		
		#=============================
		# End of Attack Code
		#=============================
		
		# Let the ai know that the uninterruptable action is complete
		_uninterrupted_action = false
		
		# Reset the attack cooldown timer
		_attack_cooldown_timer = 0.0
	
# Sets the direction facing to the opposite of it's current direction
func turn_around() -> void:
	_current_direction.x *= -1
	emit_signal("turn_around")
	
# Causes the boss to dash forward based on speed multiplier given
func dash(speed_multiplier: float = _dash_multiplier) -> void:
	if _dash_cooldown_timer >= _dash_cooldown:
		# Allow movement
		_movement_enabled = true
		# Set the velocity (simialar to how it's done in entity.gd)
		set_velocity(Vector2(get_last_direction().x * get_speed() * speed_multiplier, get_current_velocity().y))
		emit_signal("dash", speed_multiplier)

# Stops AI from running for a given time
func ai_wait(seconds: float, stop_moving: bool = true) -> void:
	_uninterrupted_action = true
	_ai_paused = true
	
	emit_signal("ai_paused", seconds)
	
	# If desired, save the last direction and stop movement
	if stop_moving:
		_movement_enabled = false
	
	_timer.start(seconds)
	yield(_timer, "timeout")
	
	_ai_paused = false
	emit_signal("ai_resumed")

	_uninterrupted_action = false
	
# Stops AI from running until resume_ai is called
func pause_ai(stop_moving: bool = true) -> void:
	_uninterrupted_action = true
	_ai_paused = true
	
	emit_signal("ai_paused", -1)
	
	# If desired, save the last direction and stop movement
	if stop_moving:
		_movement_enabled = false
	
# Unpauses the AI (if it was paused)
func resume_ai() -> void:
	if _ai_paused:
		_timer.stop()
		_uninterrupted_action = false
		_ai_paused = false
		emit_signal("ai_resumed")


#=============================
# Initializes the boss AI as an entity
# Must be called in inheriting class's _ready()
#=============================
func initialize(max_health: int, damage: int, speed: float, acceleration: float, jump_speed: float, attack_cooldown: float, dash_cooldown: float, obeys_gravity: bool, smooth_movement: bool, auto_facing: bool):
	self._max_health      = max_health
	self._ai_damage       = damage
	self._speed           = speed
	self._acceleration    = acceleration
	self._jump_speed      = jump_speed
	self._attack_cooldown = attack_cooldown
	self._dash_cooldown   = dash_cooldown
	self._obeys_gravity   = obeys_gravity
	self._smooth_movement = smooth_movement
	
	initialize_enemy(max_health, damage, speed, acceleration, jump_speed, obeys_gravity, smooth_movement)
	set_auto_facing (auto_facing)
	
	# Emit a signal for custom code purposes
	# Suggestions: Changing initial direction, setting initial animation
	emit_signal("init")

#=============================
# Getters
#=============================
# Returns the current stage that the ai is in
func get_current_ai_stage()   -> int:     return _current_ai_stage
# Returns the current state of the ai (from the STATE dictionary)
func get_current_state()      -> int:     return _current_ai_state
# Returns the attack cooldown
func get_attack_cooldown()    -> float:   return _attack_cooldown
# Returns the dash cooldown
func get_dash_cooldown()      -> float:   return _dash_cooldown
# Returns the current direction the ai is facing
func get_current_direction()  -> Vector2: return _current_direction
# Returns the value of _movement_enabled
func get_movement_enabled()   -> bool:    return _movement_enabled
# Returns whether the ai is curently moving
func is_currently_moving()    -> bool:		
	return false if _current_direction == DIRECTION.NONE else true


#=============================
# Setters
#=============================
# Sets the current stage of the ai (from STAGE dictionary)
func set_current_ai_stage(id: int) -> void:
	if id in STAGE.values():
		var temp_id: int = _current_ai_stage
		_current_ai_stage = id
		emit_signal("stage_change", id, _current_ai_stage)
	else:
		var temp_id: int = _current_ai_stage
		_current_ai_stage = STAGE.NONE
		emit_signal("stage_change", STAGE.NONE, _current_ai_stage)
		
# Sets the current state of the ai (from STATE dictionary)
func set_current_state(state: int) -> void:
	if state in STATE.values():
		_current_ai_state = state
	else:
		_current_ai_state = STATE.NONE
		
# Sets the cooldown for an attack
func set_attack_cooldown(cooldown: float) -> void:
	if cooldown >= 0.0:
		_attack_cooldown = cooldown
	
# Sets the cooldown for a dash
func set_dash_cooldown(cooldown: float) -> void:
	if cooldown >= 0.0:
		_dash_cooldown = cooldown
		
# Set the curent direction moving
func set_movement_direction(direction: Vector2):
	# Holds the Vector for the analyzed direction
	var analyzed_direction: Vector2 = Vector2(0.0, 0.0)
	# Stores whether the direction was changed from left to right or visa versa
	var direction_changed:  bool    = false
	
	# Set the analyzed direction based on the sign of the direction given
	if direction.x != 0.0:
		analyzed_direction.x = 1 * sign(direction.x)
		
	if direction.y != 0.0:
		analyzed_direction.y = 1 * sign(direction.y)
	
	# Checks if current direction is the same as the old direction
	if sign(analyzed_direction.x) != sign(_current_direction.x):
		direction_changed = true
	
	# Set the current direction to the analyzed direction
	_current_direction = analyzed_direction
	
	# Only emit a turn_around signal if the direction was changed.
	# This is purposely done after the _current_direction has been changed.
	if direction_changed:
		emit_signal("turn_around")
	
# Set the movement to enabled or disabled
func set_movement_enabled(enabled: bool):
	_movement_enabled = enabled

#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#
# Calls custom code for flipping the boss. Use if the automatic flipping code doesn't cut it.
func _flip() -> void:
	# Remember that the sprite is flipped to the right
	_sprite_flipped = !_sprite_flipped
	emit_signal("flip", Vector2(_current_direction.x, 0.0))
