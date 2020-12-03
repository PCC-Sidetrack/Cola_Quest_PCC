#-----------------------------------------------------------------------------#
# File Name:   player.gd
# Description: The controls and physics for the player entity
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        November 8, 2020
#-----------------------------------------------------------------------------#

extends Entity

# The player is the main character in the game
# The player can be controlled and interacts with the world around it

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var accelleration:        float = 20.0
export var damage:               int   = 5
export var debug:                bool  = false
export var health:               int   = 20
#export var jump_height:          float = 4.5
#export var jump_speed:           float = 0.05
export var jump_speed:           float = 850.0
export var knockback_multiplier: float = 3.0
export var speed:                float = 8.0

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
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const _COYOTE_TIME:  float = 0.12
const _DASH_REFRESH: float = 0.5
const _MAX_JUMPS:    int   = 2
const _MAX_DASHES:   int   = 1
const CONTROLS: Dictionary = {
	#"CLIMB":      "climb",
	#"CROUCH":     "crouch",
	"DASH":       "dash",
	#"INTERACT":   "interact",
	"JUMP":       "jump",
	#"MELEE":      "melee",
	"MOVE_LEFT":  "move_left",
	"MOVE_RIGHT": "move_right",
	#"RANGED":     "ranged",
}
const SPRITE: Dictionary = {
	"DASH": "dash",
	"IDLE": "idle",
	"JUMP": "jump",
	"WALK": "walk",
}

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	_check_configuration()
	
	initialize_player       (health, damage, speed, accelleration, jump_speed, true)
	set_knockback_multiplier(3.0)
	set_debug               (debug)
	
	_switch_sprite          (SPRITE.IDLE)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _process(delta: float) -> void:
	Globals.player_position = self.global_position

func _physics_process(delta: float) -> void:
	move_dynamically(_get_input())
	_refresh        (delta)

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Check to make sure the project settings have been configured correctly to interact with the player and the environment
func _check_configuration() -> void:
	for control in CONTROLS:
		if not InputMap.has_action(CONTROLS[control]):
			ProgramAlerts.add_error("InputMap missing control: " + CONTROLS[control])

# Based on what controls are currently being pressed, return a direction for the player to move
func _get_input() -> Vector2:
	var direction: float = Input.get_action_strength(CONTROLS.MOVE_RIGHT) - Input.get_action_strength(CONTROLS.MOVE_LEFT)
	
	if direction > 0.0:
		set_direction_facing(Globals.DIRECTION.RIGHT)
	elif direction < 0.0:
		set_direction_facing(Globals.DIRECTION.LEFT)
	
	# If the player can jump, then jump
	if (Input.is_action_just_pressed(CONTROLS.JUMP) and _remaining_jumps > 0):
		if get_time_in_air() < _COYOTE_TIME:
			jump(1.0)
		else:
			jump(0.75)
		_remaining_jumps -= 1
	
	if Input.is_action_just_pressed(CONTROLS.DASH) and _dash_cooldown >= _DASH_REFRESH and _remaining_dashes >= _MAX_DASHES:
		set_velocity(Vector2(get_last_direction().x * get_speed() * 3.0, get_current_velocity().y))
		_dash_cooldown     = 0.0
		_remaining_dashes -= 1
	
	_set_sprite(direction)
	
	return Vector2(direction, 0.0)

# Refresh the player metadata accordingly to changes
func _refresh(delta: float) -> void:
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

# Set which sprite is currently displayed
func _set_sprite(direction: float) -> void:
	# Change the direction the sprite is facing and flip the collision box
	if direction > 0.0:
		set_direction_facing(Globals.DIRECTION.RIGHT)
	elif direction < 0.0:
		set_direction_facing(Globals.DIRECTION.LEFT)
	elif is_on_floor():
		_switch_sprite(SPRITE.IDLE)
	
	# Display the appropriate animation
	if is_on_floor():
		if _dash_cooldown < 0.3:
			#$AnimatedSprite.play("dash")
			pass
		elif direction != 0.0:
			_switch_sprite(SPRITE.WALK)
	else:
		#if get_vertical_velocity() > 0.0:
			#$AnimatedSprite.play("fall")
		#else:
			_switch_sprite(SPRITE.JUMP)

# Change what the currently displaying sprite is
func _switch_sprite(new_sprite: String) -> void:
	var sprites: Array = $sprites.get_children()
	for sprite in sprites:
		sprite.visible = false
	
	$sprites.get_node(new_sprite).visible = true
	$AnimationPlayer.play(new_sprite)

