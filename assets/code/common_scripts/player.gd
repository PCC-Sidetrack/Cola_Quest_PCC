#-----------------------------------------------------------------------------#
# File Name:   player.gd
# Description: The controls and physics for the player entity
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
const _COYOTE_TIME:       float  = 0.12
# The dash input
const _DASH:              String = "dash"
# Max speed of the regular jump
const _JUMP_SPEED:        float  = 0.65
# Max speed of the in-air jump
const _DOUBLE_JUMP_SPEED: float  = 0.4
# Time needed to refresh the dash
const _DASH_REFRESH:      float  = 0.5
# The jump input
const _JUMP:              String = "jump"
# The maximum number of jumps the player can make before touching a wall or the floor
const _MAX_JUMPS:         int    = 2
# The maximum number of in air dashes
const _MAX_DASHES:        int    = 1
# The melee attack input
const _MELEE_ATTACK:      String = "melee_attack"
# The move_left input
const _MOVE_LEFT:         String = "move_left"
# The move_right input
const _MOVE_RIGHT:        String = "move_right"
# The ranged attack input
const _RANGED_ATTACK:     String = "ranged_attack"

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
	_check_configuration()
	
	set_damage          (5)
	set_direction_facing(1.0)
	set_max_health      (30)
	set_obeys_gravity   (true)
	set_speed           (200.0, 850.0)
	set_type            ("neutral")
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
	if Input.is_action_just_pressed(_DASH) and _dash_cooldown >= _DASH_REFRESH and _remaining_dashes >= _MAX_DASHES:
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
# Check to see if the programmer has correctly configured their project
func _check_configuration() -> void:
	if InputMap.has_action(_JUMP) and InputMap.has_action(_MOVE_LEFT) and InputMap.has_action(_MOVE_RIGHT) and InputMap.has_action(_DASH) and InputMap.has_action(_MELEE_ATTACK) and InputMap.has_action(_RANGED_ATTACK):
		pass
	else:
		push_error("Unable to control character.\nInputMap not correctly configured.")
		get_tree().quit(-1)
		
# Get the input from player
func _get_input() -> float:
	var direction = Input.get_action_strength(_MOVE_RIGHT) - Input.get_action_strength(_MOVE_LEFT)
	
	# If the player can jump, then jump
	if (Input.is_action_just_pressed(_JUMP) and _remaining_jumps > 0):
		if get_time_in_air() < _COYOTE_TIME:
			jump(_JUMP_SPEED)
		else:
			jump(_DOUBLE_JUMP_SPEED)
		_remaining_jumps -= 1
	
	# Set which direction the sprite is facing based on input
	_set_sprite(direction)
	
	return direction

# Handle entity collisions
func _on_hitbox_body_entered(body: Node) -> void:
	# Interactions with collectibles
	if body.get_type() == 1:
		body.delete()
	# Interactions with enemies
	elif body.get_type() == -1:
		knockback(body.position.x)

# Set which sprite is currently displayed
func _set_sprite(direction: float) -> void:
	# Change the direction the sprite is facing and flip the collision box
	if direction > 0.0:
		$AnimatedSprite.flip_h              = false
		$CollisionShape2D.position.x        = -abs($CollisionShape2D.position.x)
		$hitbox/CollisionShape2D.position.x = -abs($hitbox/CollisionShape2D.position.x)
	elif direction < 0.0:
		$AnimatedSprite.flip_h              = true
		$CollisionShape2D.position.x        = abs($CollisionShape2D.position.x)
		$hitbox/CollisionShape2D.position.x = abs($hitbox/CollisionShape2D.position.x)
	elif is_on_floor():
		$AnimatedSprite.play("idle")
	
	# Display the appropriate animation
	if is_on_floor():
		if _dash_cooldown < 0.3:
			#$AnimatedSprite.play("dash")
			pass
		elif direction != 0.0:
			$AnimatedSprite.play("walk")
	else:
		#if get_vertical_velocity() > 0.0:
			#$AnimatedSprite.play("fall")
		#else:
			$AnimatedSprite.play("jump")
