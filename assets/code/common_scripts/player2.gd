#-----------------------------------------------------------------------------#
# File Name:   player2.gd
# Description: The controls and physics for the player entity
# Author:      Andrew Zedwick & Jeff Newell
# Company:     Sidetrack
# Date:        December 1, 2020
#-----------------------------------------------------------------------------#

extends Entityv2

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
# Acceleration: x = horizontal, y = vertical acceleration
const _ACCELERATION: Vector2 = Vector2(30.0, 30.0)

# Base damage player deals to other entities
const _BASE_DAMAGE: int = 10
# Maximum health of the player
const _MAX_HELATH:  int = 100
# The maximum number of jumps the player can make before touching a wall or the floor
const _MAX_JUMPS:   int = 2
# The maximum number of in air dashes
const _MAX_DASHES:  int = 1

# Maximum amount of time the player has after they step off a ledge to jump
const _COYOTE_TIME:        float  = 0.12
# Time needed to refresh the dash
const _DASH_REFRESH:       float = 0.5
# Jump height
const _JUMP_HEIGHT:        float = 100.0
# Double jump hieght
const _DOUBLE_JUMP_HEIGHT: float = _JUMP_HEIGHT * 0.75
# The movement speed of the player
const _MOVEMENT_SPEED:     float = 4.0
# The movement speed of the player while dashing
const _DASH_SPEED:		   float = _MOVEMENT_SPEED * 3.0

# The dash input
const _DASH:          String = "dash"
# The jump input
const _JUMP:          String = "jump"
# The melee attack input
const _MELEE_ATTACK:  String = "melee_attack"
# The move_left input
const _MOVE_LEFT:     String = "move_left"
# The move_right input
const _MOVE_RIGHT:    String = "move_right"
# The ranged attack input
const _RANGED_ATTACK: String = "ranged_attack"

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Time between dashes
var _dash_cooldown:    float = _DASH_REFRESH
# How many dashes the player has left in air
var _remaining_dashes: int   = _MAX_DASHES
# How many jumps the player has left
var _remaining_jumps:  int   = _MAX_JUMPS

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
# Initialize the player
func _ready():
	_check_configuration()
	initialize_player(_MAX_HELATH, _BASE_DAMAGE, _MOVEMENT_SPEED, _ACCELERATION.x, _ACCELERATION.y, true, true)

#-----------------------------------------------------------------------------#
#                            Public Functions                                 #
#-----------------------------------------------------------------------------#	

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	_check_movement()
	_check_dash    (delta)
	_check_jump    ()
	
# Check for movement commands and initiate movement if needed
func _check_movement() -> void:
	var moving_right: bool = false
	var moving_left:  bool = false
	
	# Check for left and right movemenet
	if Input.is_action_pressed(_MOVE_RIGHT):
		moving_right = true
		
	if Input.is_action_pressed(_MOVE_LEFT):
		moving_left = true
		
	# If both right and left keys are pressed at the same time, then don't allow movement
	if moving_right and moving_left:
		moving_right = false
		moving_left  = false
		
	# Move the player according to the movement direction
	if moving_left:
		move_dynamically(Vector2.LEFT)
	elif moving_right:
		move_dynamically(Vector2.RIGHT)
	
# Checks for a dash and initiates dash movement if needed
func _check_dash(delta: float) -> void:
	# Dash if allowed
	if Input.is_action_just_pressed(_DASH) and _dash_cooldown >= _DASH_REFRESH and _remaining_dashes >= _MAX_DASHES:
		set_speed(_DASH_SPEED)
		
		if get_last_direction().x >= 0.0:
			move_dynamically(Vector2.RIGHT)
		else:
			move_dynamically(Vector2.LEFT)
			
		set_speed(_DASH_SPEED)
		_dash_cooldown     = 0.0
		_remaining_dashes -= 1
		
	# Refresh the dash cooldown
	if (_dash_cooldown < _DASH_REFRESH):
		_dash_cooldown += delta
		
	# Reset the number of dashes when the character is on the floor
	if is_on_floor():
		_remaining_dashes = _MAX_DASHES
	
# Checks for jump controlls and initiates a jump if needed
func _check_jump() -> void:
	# Perform a jump if action is pressed and is possible
	if (Input.is_action_just_pressed(_JUMP) and _remaining_jumps > 0):
		if get_time_in_air() < _COYOTE_TIME:
			jump(_JUMP_HEIGHT)
		else:
			jump(_DOUBLE_JUMP_HEIGHT)
		_remaining_jumps -= 1
	
	# Reset the number of jumps when the character is on the floor
	if is_on_floor():
		_remaining_jumps = _MAX_JUMPS
	
# Check to see if the programmer has correctly configured their project
func _check_configuration() -> void:
	var error_occured: bool = false
	
	if not InputMap.has_action(_JUMP):
		push_error("Unable to control character. _JUMP control not properly configured to: \"" + _JUMP + "\"")
		error_occured = true
	
	if not InputMap.has_action(_MOVE_LEFT):
		push_error("Unable to control character. _MOVE_LEFT control not properly configured to: \"" + _MOVE_LEFT + "\"")
		error_occured = true
	
	if not InputMap.has_action(_MOVE_RIGHT):
		push_error("Unable to control character. _MOVE_RIGHT control not properly configured to: \"" + _MOVE_RIGHT + "\"")
		error_occured = true
	
	if not InputMap.has_action(_DASH):
		push_error("Unable to control character. _DASH control not properly configured to: \"" + _DASH + "\"")
		error_occured = true
	
	if not InputMap.has_action(_MELEE_ATTACK):
		push_error("Unable to control character. _MELEE_ATTACK control not properly configured to: \"" + _MELEE_ATTACK + "\"")
		error_occured = true
	
	if not InputMap.has_action(_RANGED_ATTACK):
		push_error("Unable to control character. _RANGED_ATTACK control not properly configured to: \"" + _RANGED_ATTACK + "\"")
		error_occured = true

	if error_occured:
		get_tree().quit(-1)
		
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Handle entity collisions
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Interactions with collectibles
	if body.has_method("get_type"):
		if body.get_type() == 1:
			body.delete()
		# Interactions with spawnpoints
		elif body.get_type() == Globalsv2.LAYER.SPAWNPOINT:
			if !body.get_activation_status():
				set_spawn_point(body.global_position)
				body.activate()
