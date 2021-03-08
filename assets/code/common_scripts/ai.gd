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
#    - Movement:   Handled by jump(multiplier), get_movement_direction(), set_movement_direction(),
#                  is_currently_moving(), get_movement_enabled(), and set_movement_enabled()
#                  Use these methods to control when and where the entiy is moving.
#                  Movement occurs automatically every physics process.
#    - AI:         AI is handled through custom stage triggers. Use the STAGE
#                  dictionary to call set_current_ai_stage(). A function for each
#                  stage is called depending upon th current stage. Signals are
#                  used to create your custom stage.
#                  get_current_ai_stage() allows you to detect when the ai is in
#                  a current stage. A signal is emitted with the last and new stage
#                  when a stage change occurs.
#   - State Stack: The push_state_stack() and pop_state_stack() methods manipulate a 
#                  stack that can only contain values from the STATE dictionary. This
#                  stack can be used by inheriting scripts for various purposes. For
#                  example, you may want to add a state which your ai should be in at a
#                  future cycle of your script. You could save it for later by using this
#                  stack.
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
signal flipped(h_direction_facing)
# Signal is sent whenever a change in the stage of the ai is made through set_current_ai_stage()
signal stage_changed(previous_stage, new_stage)
# Signal is sent whenever any ai stage is run
signal stage_ran(stage_number)
# Signal emitted whenever the attack() method is called
signal attacked()
# Signal emitted whenever the turn_around() method is called
signal turned_around(h_new_direction)
# Signal emitted whenever a dash() is performed
signal dashed(multiplier)
# Signal emitted whenever the ai was just paused. Pausing the ai doesn't stop all
# functions of the ai (it's not static in other words) but it does prevent any
# of the ai stages from being activated for the given amount of time
signal ai_paused(num_seconds)
# Signal emitted whenever the ai is unpaused (either at the end of the pause_ai()
# mehtod or when the resume_ai() mehtod is called)
signal ai_resumed(was_waiting)

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
	MOVING4    = 3,
	MOVING5    = 4,
	MOVING6    = 5,
	JUMPING    = 6,
	ATTACKING1 = 7,
	ATTACKING2 = 8,
	ATTACKING3 = 9,
	ATTACKING4 = 10,
	ATTACKING5 = 11,
	ATTACKING6 = 12,
	WAITING1   = 13,
	WAITING2   = 14,
	WAITING3   = 15,
	CUSTOM1    = 16,
	CUSTOM2    = 17,
	CUSTOM3    = 18,
	CUSTOM4    = 19,
	CUSTOM5    = 20,
	CUSTOM6    = 21
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

#=============================
# Floats
#=============================

# Indicates the cooldown for dashing (in seconds)
# Should be same as or less than attack cooldown if used in an attack action
var _dash_cooldown:         float = 1.0
# Tracks the cooldown for dashing
var _dash_cooldown_timer:   float = 0.0
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
# Tracks whether the ai is permanantly paused until resumed through resume_ai()
var _ai_paused:            bool = false
# Tracks whether ai_wait() is currently in action (ai is paused temporarily. _ai_paused
# tracks if it is permanantly paused until resumed.)
var _ai_waiting:           bool = false

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
var _ai_timer:    Timer = Timer.new()
# Stack which holds ai states. This is for use, if desired, in any script extending
# ai.gd.
var _state_stack: Array = []

#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialze class variables
	_current_direction = DIRECTION.NONE

	# Setup the timer
	add_child(_ai_timer)
	_ai_timer.set_one_shot(true)
	
# Runs every physics engine update
func _physics_process(delta) -> void:
	# Update timers that rely on delta
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
		if !_ai_paused:
			match _current_ai_stage:
				STAGE.ONE:
					emit_signal("stage_ran", STAGE.ONE)
				STAGE.TWO:
					emit_signal("stage_ran", STAGE.TWO)
				STAGE.THREE:
					emit_signal("stage_ran", STAGE.THREE)
				STAGE.FOUR:
					emit_signal("stage_ran", STAGE.FOUR)
				STAGE.FINISHED:
					emit_signal("stage_ran", STAGE.FIVE)
				_:
					emit_signal("stage_ran", STAGE.NONE)

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

# Add a STATE to the state stack
func push_state_stack(state: int) -> void:
	if state in STATE.values():
		_state_stack.push_front(state)
		
# Pop a STATE off the state stack
func pop_state_stack() -> int:
	return _state_stack.pop_front()


#=============================
# AI Actions
#=============================
# Attack action
func attack(uninterruptable: bool = true) -> void:
	# Let the ai know that an uninterruptable action is occuring
	if uninterruptable:
		_uninterrupted_action = true
	
	#=============================	
	# Attack Code
	#=============================
	
	# Emit a signal to allow custom code to occur before the action is finished
	emit_signal("attacked")
	
	# NOTE: emit_signal does not wait until code connected to the signal is finished
	#       before moving on.
	#=============================
	# End of Attack Code
	#=============================
	
	# Let the ai know that the uninterruptable action is complete
	_uninterrupted_action = false

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
		set_velocity(Vector2(_current_direction.x * get_speed() * speed_multiplier, _current_direction.y))
		emit_signal("dash", speed_multiplier)

# Stops AI from running for a given time
func ai_wait(seconds: float, stop_moving: bool = true) -> void:
	_uninterrupted_action = true
	_ai_paused  = true
	_ai_waiting = true
	
	emit_signal("ai_paused", seconds)
	
	# If desired, save the last direction and stop movement
	if stop_moving:
		_movement_enabled = false
	
	_ai_timer.start(seconds)
	yield(_ai_timer, "timeout")
	
	_ai_paused  = false
	_ai_waiting = false
	emit_signal("ai_resumed", true)

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
# Doesn't unpause the wait timer from ai_wait() unless force parameter is true
func resume_ai(force: bool = false) -> void:
	if _ai_paused:
		if force or !_ai_waiting:
			_ai_timer.stop()
			_ai_paused = false
		
		_uninterrupted_action = false
		emit_signal("ai_resumed", false)

#=============================
# Initializes the boss AI as an entity
# Must be called in inheriting class's _ready()
#=============================
func initialize(max_health: int, damage: int, speed: float, acceleration: float, jump_speed: float, dash_cooldown: float, obeys_gravity: bool, smooth_movement: bool, auto_facing: bool):
	self._dash_cooldown   = dash_cooldown
	
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
# Returns the dash cooldown
func get_dash_cooldown()      -> float:   return _dash_cooldown
# Returns the current direction the ai is facing
func get_current_direction()  -> Vector2: return _current_direction
# Returns whether the ai is currently paused
func get_ai_paused()          -> bool:    return _ai_paused
# Returns the value of _movement_enabled
func get_movement_enabled()   -> bool:    return _movement_enabled
# Returns the ai STATE stack
func get_state_stack()        -> Array:   return _state_stack
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
	emit_signal("turned_around", Vector2(_current_direction.x, 0.0))
