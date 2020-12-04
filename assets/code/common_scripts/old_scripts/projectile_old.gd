#-----------------------------------------------------------------------------#
# File Name:   	3by5_projectile.gd                                            #
# Description: 	Contains the code for directing a 3x5 card projectile         #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends    EntityOld
class_name Projectile

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
var _target_position: Vector2 = Globals.player_position
# Target Node
var _target:          Node2D  = null
# Whether the projectile targets the player
var _homing:          bool    = false
# Whether the projectile rotates while hominb
var _rot_homing:      bool    = false
# False if rotation has not yet been initially set
var _rot_init_set:	  bool    = false
# Multiplied by the angle to allow simple flipping of rotations
var _rot_multiplier:  float   = 1.0
# Holds the acceleration of the projectile
var _acceleration: 	  Vector2 = Vector2.ZERO
# Speed of the projectile
var _proj_speed:      float   = 100.0
# Initial velocity of projectile
var _velocity: 	  	  Vector2 = Vector2.ZERO
# Steer force of projectile while changing target positions
var _steer_force:  	  float   = 50.0
# Timer controlling how long before the projectile is deleted
var _proj_timer:      float  = 0.0
# Life of the projectile in seconds
var _proj_life:       float  = 1.0

#-----------------------------------------------------------------------------#
#                               Constructor                                   #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	# TODO: Add timer that deletes entity after timeout
	set_obeys_gravity(true)
	set_type("projectile")

#-----------------------------------------------------------------------------#
#                            Public Functions                                 #
#-----------------------------------------------------------------------------#
# Initialize the projectile
func initialize(homing: bool, speed: float = _proj_speed, lifetime: float = _proj_life,
		rot_homing: bool = _rot_homing, rot_multiplier: float = _rot_multiplier,
		target: Node2D = self._target, target_position: Vector2 = _target_position,
		init_velocity:   Vector2 = _velocity, steer_force: float  = _steer_force) -> void:
	
	# Set all of the initial variables for the projectile depending on their nullity
	_homing = homing
	_proj_speed  	 = speed
	_proj_life       = lifetime
	_rot_homing      = rot_homing
	_rot_multiplier  = rot_multiplier
	steer_force 	 = steer_force
	_target_position = target_position
	_target          = target	
		
	# Only set the starting _velocity if it was given and homing is on
	if init_velocity != null and homing == true:
		_velocity = init_velocity

# Calculate the velocity needed to collide with the current position of the player
func steer_at_target() -> Vector2:
	# Set the desired velocity needed to collide with the target position
	var desired_velocity: Vector2 = (_target_position - global_position).normalized() * _proj_speed
	var steer:            Vector2 = Vector2.ZERO
	
	# Set the steer force to be added to the _acceleration of the projectile
	if _homing:
		steer = (desired_velocity - _velocity).normalized() * _steer_force
	else:
		steer = desired_velocity
		
	if _homing and _rot_homing:
		rotation = (steer * _rot_multiplier).angle()
		
	# Add the steer force to the acceleration vector of the projectile
	_acceleration += steer
	
	return steer
	
# Called whenever the projectile collides with something
func on_projectile_collision() -> void:
	queue_free()
	
# Called when the projecile's lifetime timer ends
func on_exceeds_lifetime() -> void:
	queue_free()

#-----------------------------------------------------------------------------#
#                            Setter Functions                                 #
#-----------------------------------------------------------------------------#

# Set the target position
func set_target_position(position: Vector2) -> void:
	_target_position = position
	
# Set the target node
func set_target_node(target: Node2D, homing = true) -> void:
	_target = target
	_homing = homing
	
# Set whether the projectile is homing
func set_homing(homing: bool, position: Vector2 = _target_position) -> void:
	_homing = homing

# Set the current acceleration: NOTE - This should not normally be changed
func set_acceleration(acceleration: Vector2) -> void:
	_acceleration = acceleration
	
# Set the projectile speed
func set_projectile_speed(speed: float) -> void:
	_proj_speed = speed
	
# Set the projectile velocity
func set_projctile_velocity(velocity: Vector2) -> void:
	_velocity = velocity
	
# Set the projectile steer force (only effective if projectile is homing
func set_steer_force(force: float) -> void:
	_steer_force = force
	
# Set the life of the projectile
func set_projectile_max_lifetime(lifetime: float) -> void:
	_proj_life = lifetime
	
#-----------------------------------------------------------------------------#
#                            Getter Functions                                 #
#-----------------------------------------------------------------------------#
	
# Return the projectile's current homing position
func get_target_position() -> Vector2:
	return _target_position
	
# Return the target node for the projectile
func get_target_node() -> Node2D:
	return _target
	
# Return whether the projectile is homing or not
func get_homing() -> bool:
	return _homing
	
# Return the current acceleration of the Projectile
func get_acceleration() -> Vector2:
	return _acceleration
	
# Return the projectile's speed
func get_projectile_speed() -> float:
	return _proj_speed

# Return the current velocity of the projectile
func get_projectile_velocity() -> Vector2:
	return _velocity
	
# Return the steer force of the projectile: only effective if homing is true
func get_steer_force() -> float:
	return _steer_force
	
# Return how long the projectile has been alive
func get_projectile_lifetime() -> float:
	return _proj_timer
	
# Return the lifetime of the projectile
func get_projetile_max_lifetime() -> float:
	return _proj_life

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Physics process for 3x5 card
func _physics_process(delta: float) -> void:
	# Steer the projectile's acceleration towards the current target if homing
	if _homing:
		# If target is left as null, then direct the projectile towards the player
		if _target != null:
			set_target_position(_target.global_position)
		else:
			set_target_position(Globals.player_position)
		
	# Set the projectile's current velocity
	var steer: Vector2 =  steer_at_target()
	
	_velocity += _acceleration * delta
	_velocity = _velocity.clamped(_proj_speed)
	
	# Set the initial rotation
	if not _rot_init_set:
		rotation = (steer * _rot_multiplier).angle()
		_rot_init_set = true
		
	# Move the projectile towards the current position using its velocity
	var collision = self.move_and_collide(_velocity * delta)
	
	# Check if a collision has occurd and if so, do action specified in function
	if collision != null:
		on_projectile_collision()
		
	# Update the lifetime timer and check that the maximum lifetime of the
	# projectile has not been exceded
	_proj_timer += delta
	
	if _proj_timer >= _proj_life:
		print("proj deleted")
		on_exceeds_lifetime()
