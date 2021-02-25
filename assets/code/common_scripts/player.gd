#-----------------------------------------------------------------------------#
# Class Name:    player.gd
# Description:  The controls and physics for the player entity
# Author:       Jeff Newell (mostly) & Andrew Zedwick
# Company:      Sidetrack
# Last Updated: December 8, 2020
#-----------------------------------------------------------------------------#

extends Entity

# The player is the main character in the game
# The player can be controlled and interacts with the world around it

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var accelleration:        float   = 15.0
export var friction:             float   = 25.0
export var camera_zoom:          Vector2 = Vector2(1.5, 1.5)
export var original_zoom:        float   = 1.0
export var damage:               int     = 1
export var debug:                bool    = false
export var max_health:           int     = 5
export var invlunerability_time: float   = 1.5
#export var jump_height:         float   = 4.5
#export var jump_speed:          float   = 0.05
export var jump_speed:           float   = 850.0
export var knockback_multiplier: float   = 3.0
export var speed:                float   = 8.0


#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Time between dashes
var _dash_cooldown:     float = _DASH_REFRESH
# How many dashes the player has left in air
var _remaining_dashes:  int   = _MAX_DASHES
# How many jumps the player has left
var _remaining_jumps:   int   = _MAX_JUMPS
# Holds the inital zoom
var _init_camera_zoom:  Vector2
# Specifies the speed that the camera is zoomed to a new location
var _camera_zoom_speed: int   = 5
# Holds the current zoom of the camera. Used for smooth zoom changes
var _current_zoom
# Indicates if the player is currently dead and respawning
var _dead:              bool  = false


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
	# Set the global player reference variable
	Globals.player = get_node(self.get_path())
	
	# Save the initial and current camera zoom
	_init_camera_zoom = camera_zoom
	_current_zoom     = camera_zoom
	
	_check_configuration()
	
	initialize_player       (max_health, damage, speed, accelleration, jump_speed, true)
	set_knockback_multiplier(3.0)
	set_is_dead             (false)
	set_debug               (debug)
	
	# Sends the maximum health to the game_UI
	get_node("game_UI").on_initialize_player(get_max_health())
	
	# Check that the player health bar has been added as a child of the player node
	if not has_node("game_UI"):
		ProgramAlerts.add_error("The player node doesn't have the \'game_UI\' node as a child. This node should be added with the given name assigned.")
		
	
	_switch_sprite          (SPRITE.IDLE)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Set the speed that the camera is zoomed in and out
func set_camera_zoom_speed(cam_speed: int) -> void:
	_camera_zoom_speed = cam_speed
	
# Get the speed that the camera is zoomed in and out
func get_camera_zoom_speed() -> int:
	return _camera_zoom_speed
	
# Resets the zoom of the camera to the inital zoom
func reset_camera_zoom() -> void:
	camera_zoom = _init_camera_zoom
	
# Zooms the camera based on the multiplier given and returns the desired zoom vector
func zoom(multiplier: float) -> Vector2:
	camera_zoom = camera_zoom * multiplier
	return camera_zoom
	
# Returns a boolean based on whether the player is currently respawing from a death
func is_dead() -> bool:
	return _dead
	
# Sets the value of the 'dead' boolean. When dead, the player can't take damage.
func set_is_dead(value: bool) -> void:
	_dead = value

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(delta: float) -> void:
	# Get the movement vector from the player input
	var input: Vector2 = _get_input()
	
	# Set the current position of the player
	Globals.player_position = self.global_position
	
	# Check if the input has no horizontal movement, if so, temporarily
	# change the acceleration to the friction value
	if input.x == 0.0:
		move_dynamically(input, friction)
	else:
		move_dynamically(input)
	
	_refresh        (delta)
	
	# Set the camera's zoom smoothly
	if _current_zoom != camera_zoom:
		_current_zoom = lerp(_current_zoom, camera_zoom, _camera_zoom_speed * delta)
	
		$Camera2D.zoom = _current_zoom
	

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
	var velocity: Vector2 = Vector2(0.0, 0.0)
	
	# Only check for control changes if the game isn't locked
	if !Globals.game_locked:
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
			set_velocity(Vector2(get_last_direction().x * get_speed() * 2.5, get_current_velocity().y))
			_dash_cooldown     = 0.0
			_remaining_dashes -= 1
		
		_set_sprite(direction)
		velocity.x = direction
	
	return velocity

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

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# Triggered whenever the player collides with something
func _on_player_collision(body) -> void:
	if body.has_method("is_in_group"):
		if body.is_in_group(Globals.GROUP.ENEMY) or body.is_in_group(Globals.GROUP.PROJECTILE):
			take_damage(body.get_damage())
			knockback(body)

# Triggered whenever the player's health is changed
func _on_player_health_changed(change) -> void:
	# If the player would be damaged, isn't invunerable, and isn't already dead,
	# then process the damage
	if change < 0 and !get_invulnerability() and !is_dead():
		# Update the GUI, print out the damage taken, and make the player invunerable for a bit
		get_node("game_UI").on_player_health_changed(get_current_health(), get_current_health() - change)
		set_invulnerability(invlunerability_time)
	# If the player would be healed, then update the GUI
	elif change > 0:
		get_node("game_UI").on_player_health_changed(get_current_health(), get_current_health() - change)
		
	if change < 0 && get_current_health():
		flash_damaged()	

# Triggered whenever the player dies
func _on_player_death() -> void:
	if !is_dead():
		death_anim()
		set_is_dead(true)
		
		# Lock the game and have a short cooldown before respawning
		set_invulnerability(100000.0)
		Globals.game_locked = true
		
		# Display failure screen on player death 
		$game_UI.on_player_killed()

# Triggered whenever the player respawns
func _on_game_UI_respawn_player() -> void:
	# Respawn
	global_position = get_spawn_point()
	set_invulnerability(invlunerability_time)
	set_is_dead(false)
	print("\nPlayer Respawning...")
	set_modulate(Color(1, 1, 1, 1))
	print("\nColor Modulated")
	set_current_health(max_health)
	take_damage(-max_health)
	Globals.game_locked = false
