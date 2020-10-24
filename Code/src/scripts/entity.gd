#-----------------------------------------------------------------------------#
# File Name:   entity.gd
# Description: The basic physics and class methods for any entity in each level
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 1, 2020
#-----------------------------------------------------------------------------#

class_name Entity
extends    KinematicBody2D

# This is the class that contains all of the basic information for any entity in a level.
# It is extendable to include AI or controls for each entity.

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const _GRAVITY: float = 2000.0
const _RIGHT:   float = 1.0
const _LEFT:    float = -1.0

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The current velocity the entity is traveling
var _current_velocity: Vector2 = Vector2.ZERO
# The damage the entity does
var _damage:           int     = 0
# What is considered to be the floor
var _floor_normal:     Vector2 = Vector2.UP
# The health of the entity
var _health:           int     = 1
# The direction the entity was last moving
var _last_direction:   float   = _RIGHT
# Whether or not the entity obeys gravity
var _obeys_gravity:    bool    = true
# How quickly the entity is changing direction
var _rate_of_change:   Vector2 = Vector2(20.0, 30.0)
# The maximum normal vertical and horizontal speeds of the entity
var _speed:            Vector2 = Vector2.ZERO
# How long the entity has been in the air
var _time_in_air:      float   = 0.0
# The time moving in a direction
var _time_in_direction: float  = 0.0
# How long the entity has been on the ground
var _time_on_ground:   float   = 0.0

#-----------------------------------------------------------------------------#
#                               Process Loop                                  #
#-----------------------------------------------------------------------------#
# Run the process loop on the entity
func _process(_delta: float) -> void:
	if _obeys_gravity:
		_update_stats()

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Calculate the horizontal velocity of the player
func calculate_horizontal_velocity(direction: float) -> float:
	if direction > 0.0 and _last_direction == _LEFT:
		_last_direction    = _RIGHT
		_time_in_direction = 0.0
	elif direction < 0.0 and _last_direction == _RIGHT:
		_last_direction    = _LEFT
		_time_in_direction = 0.0
	return move_toward(_current_velocity.x, _speed.x * direction, _rate_of_change.x)

# A quick and easy way to calculate the velocity when specific control over horizontal and vertical isn't needed
func calculate_new_velocity(direction: float) -> Vector2:
	return Vector2(calculate_horizontal_velocity(direction), calculate_vertical_velocity())

# Calculate the vertical velocity of the player
func calculate_vertical_velocity() -> float:
	return move_toward(_current_velocity.y, _GRAVITY * 0.4, _rate_of_change.y)

# Get the damage the entity does
func get_damage() -> int:
	return _damage

# Get the floor normal for calculating collision orientation
func get_floor_normal() -> Vector2:
	return _floor_normal

# Get the value of gravity
func get_gravity() -> float:
	return _GRAVITY

# Get the current health of the entity
func get_health() -> int:
	return _health

# Get the current horizontal velocity of the entity
func get_horizontal_velocity() -> float:
	return _current_velocity.x

# Get the last direction the entity was moving horizontally
func get_last_direction() -> float:
	return _last_direction

# Get the maximum vertical and horizontal speeds of the entity
func get_speed() -> Vector2:
	return _speed

# Get the time the entity has been in the air
func get_time_in_air() -> float:
	return _time_in_air

# Get the time the entity has been on the ground
func get_time_on_ground() -> float:
	return _time_on_ground

# Get the current vertical velocity of the entity
func get_vertical_velocity() -> float:
	return _current_velocity.y

# Make the entity jump
func jump(height: float) -> void:
	_current_velocity.y = _speed.y * -height

# Set the damage that the entity does
func set_damage(new_damage: int) -> void:
	_damage = new_damage
	
# Set which direction the entity is facing
func set_direction_facing(direction: float) -> void:
	if (direction >= 0.0):
		_last_direction = _RIGHT
	else:
		_last_direction = _LEFT
	
# Set the health of the entity
func set_health(new_health: int) -> void:
	_health = new_health

# Set the horizontal and vertical speed of the entity
# This is in pixels / second (velocity)
func set_speed(horizontal: float, vertical: float) -> void:
	_speed.x        = horizontal
	_speed.y        = vertical

# Set whether the entity obeys gravity
func set_obeys_gravity(boolean: bool) -> void:
	_obeys_gravity = boolean

# Set how quickly the entity changes direction vertically and horizontally
func set_rate_of_change(horizontal_change: float, vertial_change: float) -> void:
	_rate_of_change.x = horizontal_change
	_rate_of_change.y = vertial_change

# Set the current horizontal and vertical velocity of the entity
func set_velocity(velocity: Vector2) -> void:
	_current_velocity = velocity

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Update the players statistics
func _update_stats() -> void:
	if is_on_floor():
		_time_on_ground += get_physics_process_delta_time()
		_time_in_air     = 0.0
	elif not (is_on_floor() or is_on_wall()):
		_time_in_air    += get_physics_process_delta_time()
		_time_on_ground  = 0.0
	
	if _current_velocity.x != 0.0:
		_time_in_direction += get_physics_process_delta_time()
