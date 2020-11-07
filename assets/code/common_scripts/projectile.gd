#-----------------------------------------------------------------------------#
# File Name:   	3by5_projectile.gd                                            #
# Description: 	Contains the code for directing a 3x5 card projectile         #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends    Entity
class_name Projectile

#-----------------------------------------------------------------------------#
#                            Public Variables                                 #
#-----------------------------------------------------------------------------#
# Whether the projectile targets the player
var homing:       bool    = true
# Holds the acceleration of the projectile
var acceleration: Vector2 = Vector2.ZERO
# Speed of the projectile
var speed:        int     = 100
# Initial velocity of projectile
var velocity: 	  Vector2 = Vector2.ZERO
# Steer force of projectile while changing target positions
var steer_force:  float   = 50.0

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
var _target_position: Vector2 = Globals.player_position
# Target Node
var target:       Node2D = null
#-----------------------------------------------------------------------------#
#                               Constructor                                   #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	# TODO: Add timer that deletes entity after timeout
	set_obeys_gravity(true)
	set_type("projectile")
	set_knockback_multiplier(0.1)
	steer_at_target()
	$AnimatedSprite.play("spin")

#-----------------------------------------------------------------------------#
#                            Public Functions                                 #
#-----------------------------------------------------------------------------#
# Initialize the projectile
func initialize(homing: bool, target: Node2D = self.target,
		target_position: Vector2 = _target_position, speed: int = self.speed,
		init_velocity:   Vector2 = velocity, steer_force: float = self.steer_force) -> void:
	# Set all of the initial variables for the projectile
	self.homing      = homing
	self.speed       = speed
	self.steer_force = steer_force
	
	# Only set the velocity if homing is not enabled and target position wasn't given
	if not homing and target_position == null:
		self.velocity    = init_velocity
	
	# Only set the target position and target if they are not null
	if target_position != null:
		_target_position = Globals.player_position
	if target != null:
		self.target = target
	

# Calculate the velocity needed to collide with the current position of the player
func steer_at_target() -> Vector2:
	# Set the desired velocity needed to collide with the target position
	var desired_velocity: Vector2 = (_target_position - global_position).normalized() * speed
	var steer:            Vector2 = Vector2.ZERO
	
	# Set the steer force to be added to the acceleration of the projectile
	if homing:
		steer = (desired_velocity - velocity).normalized() * steer_force
	else:
		steer = desired_velocity
		
	# Add the steer force to the acceleration vector of the projectile
	acceleration += steer
	
	return steer
	
# Called whenever the projectile collides with something
func on_projectile_collision() -> void:
	queue_free()
	
# Set the target position
func set_target_position(position: Vector2) -> void:
	_target_position = position
	
# Set whether the projectile is homing
func set_homing(homing: bool, position: Vector2 = _target_position) -> void:
	self.homing = homing
	
# Return the projectile's current homing position
func get_target_position() -> Vector2:
	return _target_position
	
# Return whether the projectile is homing or not
func get_homing() -> bool:
	return homing

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Physics process for 3x5 card
func _physics_process(delta: float) -> void:
	# Steer the projectile's acceleration towards the current target
	if homing:
		# If target is left as null, then direct the projectile towards the player
		if not target == null:
			set_target_position(target.global_position)
		else:
			set_target_position(Globals.player_position)
		steer_at_target()
	
		# Set the projectile's velocity based on the acceleration
		velocity += acceleration * delta
		velocity = velocity.clamped(speed)
	
	# Move the projectile towards the current position
	var collision = self.move_and_collide(velocity * delta)
	
	# Check if a collision has occurd and if so, do action specified in function
	if collision != null:
		on_projectile_collision()
		
