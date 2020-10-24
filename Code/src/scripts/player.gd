#-----------------------------------------------------------------------------#
# File Name:   player.gd
# Description: The controls and physics for the player actor
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 1, 2020
#-----------------------------------------------------------------------------#

extends Entity

# This is the script for the player.
# It allows the player to move the main character and jump when placed in a level.
# It also contains the health and other elements needed for player movement.

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
# Maximum amount of time the player has after they step off a ledge to jump
const _COYOTE_TIME:       float = 0.12
# Max speed of the in-air jump
const _DOUBLE_JUMP_SPEED: float = 0.75
# Time needed to refresh the dash
const _DASH_REFRESH:      float = 0.5
# The maximum number of jumps the player can make before touching a wall or the floor
const _MAX_JUMPS:         int   = 2
# The maximum number of in air dashes
const _MAX_DASHES:        int   = 1

#-----------------------------------------------------------------------------#
#                                Variables                                    #
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
	set_damage          (5)
	set_direction_facing(1.0)
	set_health          (30)
	set_obeys_gravity   (true)
	set_speed           (300.0, 800.0)
	set_rate_of_change  (30.0, 30.0)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
# Run the physics process on the player
func _physics_process(delta: float) -> void:
	# Calculate the horizontal velocity of the player
	var horizontal: float = calculate_horizontal_velocity(_get_input())
	# Calculate the vertical velocity of the player
	var vertical:   float = calculate_vertical_velocity()
	
	# Allow the player to dash
	if Input.is_action_just_pressed("dash") and _dash_cooldown >= _DASH_REFRESH and _remaining_dashes >= _MAX_DASHES:
		if get_last_direction() >= 0.0:
			horizontal = get_speed().x * 3.0
		else:
			horizontal = get_speed().x * -3.0
		_dash_cooldown     = 0.0
		_remaining_dashes -= 1
	
	# Calculate and move the player
	set_velocity(move_and_slide(Vector2(horizontal, vertical), get_floor_normal()))
	
	# Refresh the dash cooldown
	if (_dash_cooldown < _DASH_REFRESH):
		_dash_cooldown += delta
	
	# Reset the number of jumps when the character is on the floor or the wall
	if is_on_floor():
		_remaining_jumps  = _MAX_JUMPS
		_remaining_dashes = _MAX_DASHES
	
	# Only lets the player jump once in the air
	if get_time_in_air() >= _COYOTE_TIME and _remaining_jumps == _MAX_JUMPS:
		_remaining_jumps -= 1

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Get the input from player
func _get_input() -> float:
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	# If the player can jump, then jump
	if (Input.is_action_just_pressed("jump") and _remaining_jumps > 0):
		if get_time_in_air() < _COYOTE_TIME:
			jump(1.0)
		else:
			jump(0.75)
		_remaining_jumps -= 1
	
	# Set which direction the sprite is facing based on input
	_set_sprite(direction)
	
	return direction

# Set which sprite is currently displayed
func _set_sprite(direction: float) -> void:
	# Change the direction the sprite is facing
	if direction > 0.0:
		$AnimatedSprite.flip_h = false
	elif direction < 0.0:
		$AnimatedSprite.flip_h = true
	elif is_on_floor():
		$AnimatedSprite.play("idle")
	
	# Display the appropriate animation
	if is_on_floor():
		if _dash_cooldown < 0.3:
			$AnimatedSprite.play("dash")
		elif direction != 0.0:
			$AnimatedSprite.play("walk")
	else:
		if get_vertical_velocity() > 0.0:
			$AnimatedSprite.play("fall")
		else:
			$AnimatedSprite.play("jump")
