#-----------------------------------------------------------------------------#
# File Name:   entity.gd
# Description: The basic physics and class methods for any entity in each level
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        November 8, 2020
#-----------------------------------------------------------------------------#

class_name Entityv2
extends    KinematicBody2D

# An entity is any object that moves and interacts with the terrain
# An entity will have damage, health, and movement

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The damage the entity does
var _damage: Dictionary = {
	amount               = 0,
	knockback_multiplier = 0.5,
}

# Health data for the entity
var _health: Dictionary = {
	current                  = 1,
	invulnerability_duration = 0.0,
	maximum                  = 1,
}

# The movement information for the entity
var _movement: Dictionary = {
	acceleration          = 20.0,
	current_velocity      = Vector2.ZERO,
	#gravity               = 0.0,
	initial_jump_velocity = 0.0,
	speed                 = 0.0,
}

# Different metadata to track for the entity
var _metadata: Dictionary = {
	auto_facing         = false,
	debug               = false,
	direction_facing    = Globalsv2.DIRECTION.RIGHT,
	is_looking          = false,
	is_movement_smooth  = true,
	last_direction      = Vector2(Globalsv2.DIRECTION.RIGHT, Globalsv2.DIRECTION.UP),
	movement            = {
		current_instruction = 0,
		instructions        = {},
		is_looping          = false,
	},
	obeys_gravity       = false,
	spawn_point         = Vector2.ZERO,
	time_in_air         = 0.0,
	time_in_direction   = Vector2.ZERO,
	time_on_ground      = 0.0,
}

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	_health.current       = _health.maximum
	_metadata.spawn_point = global_position

#-----------------------------------------------------------------------------#
#                                   Loop                                      #
#-----------------------------------------------------------------------------#
func _process(delta: float) -> void:
	_update_invulnerability(delta)
	_update_last_direction ()
	_update_time_in_air    (delta)
	_update_time_on_ground (delta)
	update()

func _draw() -> void:
	if _metadata.debug:
		_show_direction()

#-----------------------------------------------------------------------------#
#                             Getter Functions                                #
#-----------------------------------------------------------------------------#
func get_current_instruction() -> int:
	return _metadata.movement.current_instruction
func get_current_health     () -> int:
	return round(_health.current) as int
func get_current_velocity   () -> Vector2:
	return _movement.current_velocity
func get_damage             () -> int:
	return round(_damage.amount) as int
func get_invulnerability    () -> bool:
	return _health.invulnerability_duration > 0.0
func get_last_direction     () -> Vector2:
	return _metadata.last_direction
func get_max_health         () -> int:
	return round(_health.maximum) as int
#func get_obeys_gravity      () -> bool:
#	return _movement.gravity > 0.0
func get_obeys_gravity      () -> bool:
	return _metadata.obeys_gravity
func get_position           () -> Vector2:
	return global_position
func get_speed              () -> float:
	return _movement.speed
func get_time_in_air        () -> float:
	return _metadata.time_in_air
func get_time_in_direction  () -> Vector2:
	return _metadata.time_in_direction
func get_time_on_ground     () -> float:
	return _metadata.time_on_ground

#-----------------------------------------------------------------------------#
#                             Setter Functions                                #
#-----------------------------------------------------------------------------#
func set_acceleration           (new_rate: float) -> void:
	_movement.acceleration = new_rate
func set_auto_facing            (is_auto_facing: bool) -> void:
	_metadata.auto_facing = is_auto_facing
func set_current_health         (new_health: int) -> void:
	_health.current = new_health
func set_damage                 (new_amount: int) -> void:
	_damage.amount = new_amount
func set_debug                  (is_showing: bool) -> void:
	_metadata.debug = is_showing
func set_direction_facing       (direction: float) -> void:
	if direction != 0.0 and _metadata.direction_facing != direction:
		_flip_entity(self)
		_metadata.direction_facing = sign(direction)
func set_invulnerability        (new_duration: float) -> void:
	_health.invulnerability_duration = new_duration
func set_sprite_facing_direction(direction: float) -> void:
	if direction != _metadata.direction_facing:
		_flip_entity(self)
#func set_jump                   (new_jump_height: float = 1.0, new_jump_time: float = 0.05) -> void:
#_movement.gravity               = Globalsv2.til2pix(new_jump_height) / new_jump_time
#_movement.initial_jump_velocity = sqrt(2 * _movement.gravity * Globalsv2.til2pix(new_jump_height))
func set_jump                   (velocity: float) -> void:
	_movement.initial_jump_velocity = velocity
func set_knockback_multiplier   (new_multiplier: float) -> void:
	_damage.knockback_multiplier = new_multiplier
func set_looking                (is_looking: bool) -> void:
	_metadata.is_looking = is_looking
func set_max_health             (new_health: int) -> void:
	_health.maximum = new_health
func set_obeys_gravity          (is_affected: bool) -> void:
	_metadata.obeys_gravity = is_affected
func set_smooth_movement        (is_smooth: bool = !_metadata.is_movement_smooth) -> void:
	_metadata.is_movement_smooth = is_smooth
func set_spawn_point            (new_point: Vector2) -> void:
	_metadata.spawn_point = new_point
func set_speed                  (new_movement_speed: float) -> void:
	_movement.speed = Globalsv2.til2pix(new_movement_speed)
func set_velocity               (new_velocity: Vector2) -> void:
	_movement.current_velocity = new_velocity

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Delete the entity
func delete() -> void:
	queue_free()

# Create a distance array instruction
func distance(direction: Vector2, distance: float) -> Array:
	return ["distance", direction, distance]

# Create a duration array instruction
func duration(direction: Vector2, duration: float) -> Array:
	return["duration", direction, duration]

# Create an end point array instruction
func end_point(destination: Vector2) -> Array:
	return ["point", destination]

# Initialize a collectable entity
func initialize_collectable() -> void:
	add_to_group   (Globalsv2.GROUP.COLLECTABLE)
	_set_layer_bits([Globalsv2.LAYER.COLLECTABLE])
	_set_mask_bits ([Globalsv2.LAYER.PLAYER])

# Initialize an enemy entity
#func initialize_enemy(health: int, damage: int, speed: float, acceleration: float = 20.0, jump_height:float = 0.0, jump_duration: float = 1.0, smooth_movement: bool = true) -> void:
func initialize_enemy(health: int, damage: int, speed: float, acceleration: float = 20.0, jump_velocity: float = 1.0, obeys_gravity: bool = false, smooth_movement: bool = true) -> void:
	add_to_group       (Globalsv2.GROUP.ENEMY)
	_set_layer_bits    ([Globalsv2.LAYER.ENEMY])
	_set_mask_bits     ([Globalsv2.LAYER.PLAYER, Globalsv2.LAYER.WORLD])
	set_acceleration   (acceleration)
	set_current_health (health)
	set_damage         (damage)
	#set_jump           (jump_height, jump_duration)
	set_jump           (jump_velocity)
	set_max_health     (health)
	set_obeys_gravity  (obeys_gravity)
	set_smooth_movement(smooth_movement)
	set_speed          (speed)

# Turn the given instructions into a movement set
# Instruction template
# - [
# -   [type, direction/endpoint, duration/distance/null],
# -   ...
# - ]
func initialize_instructions(movements: Array, is_looping: bool = false) -> void:
	for instruction in movements:
		_metadata.movement.instructions[_metadata.movement.instructions.size()] = _to_movement_set(instruction)
	_metadata.movement.is_looping = is_looping
	movements.clear()

# Initialize a player entity
#func initialize_player(health: int, damage: int, speed: float, acceleration: float, jump_height:float, jump_duration: float, smooth_movement: bool = true) -> void:
func initialize_player(health: int, damage: int, speed: float, acceleration: float, jump_velocity: float, obeys_gravity: bool = false, smooth_movement: bool = true) -> void:
	add_to_group       (Globalsv2.GROUP.PLAYER)
	_set_layer_bits    ([Globalsv2.LAYER.PLAYER])
	_set_mask_bits     ([Globalsv2.LAYER.ENEMY, Globalsv2.LAYER.COLLECTABLE, Globalsv2.LAYER.INTERACTABLE, Globalsv2.LAYER.WORLD])
	set_acceleration   (acceleration)
	set_current_health (health)
	set_max_health     (health)
	set_obeys_gravity  (obeys_gravity)
	#set_jump           (jump_height, jump_duration)
	set_jump           (jump_velocity)
	set_smooth_movement(smooth_movement)
	set_speed          (speed)

# Initialize a projectile entity
func initialize_projectile(damage: int, speed: float, initiator: String, direction: Vector2 = Vector2.RIGHT, turn_force: float = 1.0) -> void:
	add_to_group       (Globalsv2.GROUP.PROJECTILE)
	_set_layer_bits    ([Globalsv2.LAYER.PROJECTILE])
	_set_mask_bits     ([Globalsv2.LAYER.WORLD])
	set_acceleration   (turn_force)
	set_velocity       (direction.normalized() * speed)
	set_speed          (speed)
	
	match initiator:
		"player", "p":
			add_to_group(Globalsv2.GROUP.PLAYER)
		"enemy", "e":
			add_to_group(Globalsv2.GROUP.ENEMY)

# Cause the entity to jump
func jump(height: float) -> void:
	if height > 1.0 or height <= 0.0:
		ProgramAlerts.add_warning("jump height should normally be between 1.0 and greater than 0.0")
		
	_movement.current_velocity.y = _movement.initial_jump_velocity * -height

# Create a jump array instruction
func jump_inst(height: float) -> Array:
	return ["jump", height]

# Cause another entity to be knocked back
# Based on the location of the entity in relation to the entity it is knocking back
func knockback(other_entity: Entity) -> void:
	other_entity.set_velocity(global_position.direction_to(other_entity.get_position()).normalized() * other_entity.get_speed() * _damage.knockback_multiplier)

# A generic move function that determines what kind of movement the entity contains
# This is intended for more automation, but should not be considered lazy coding
# Provides minimal control over entities
# Returns whether the entity has moved
func move() -> bool:
	var current_instruction: Dictionary = _metadata.movement.instructions[_metadata.movement.current_instruction]
	var did_move:            bool       = false
	
	if _metadata.auto_facing:
		_auto_facing()
	
	if not current_instruction.is_completed:
		did_move = true
		if current_instruction.has("distance_remaining"):
			_move_distance(current_instruction)
		elif current_instruction.has("duration_remaining"):
			_move_duration(current_instruction)
		elif current_instruction.has("end_point"):
			_move_to_point(current_instruction)
		elif current_instruction.has("jump_height"):
			jump(current_instruction.jump_height)
			current_instruction.is_completed = true
		elif current_instruction.has("wait_duration"):
			_wait(current_instruction)
	
	if current_instruction.is_completed:
		_next_instruction()
	
	return did_move

# Move based on a dynamically changing horizontal direction
# Provides the finest control of entities
func move_dynamically(direction: Vector2) -> void:
	# Normalize the direction vector to reduce it to purely a direction and not a magnitude
	var horizontal: float = direction.normalized().x
	var vertical:   float = direction.normalized().y
	
	# Determine what kind of movement is being used
	# NOTE:
	#  - Entities that obey gravity must move smoothy
	#  - Entities cannot obey gravity if they do not move smoothly
	if _metadata.is_movement_smooth:
		if get_obeys_gravity():
			horizontal = move_toward(_movement.current_velocity.x, horizontal * _movement.speed, _movement.acceleration)
			#vertical   = move_toward(_movement.current_velocity.y, Globalsv2.ORIENTATION.MAX_FALL_SPEED, _movement.gravity * get_physics_process_delta_time())
			vertical   = move_toward(_movement.current_velocity.y, Globalsv2.ORIENTATION.MAX_FALL_SPEED, Globalsv2.ORIENTATION.MAX_FALL_SPEED * get_physics_process_delta_time())
		else:
			horizontal = move_toward(_movement.current_velocity.x, horizontal * _movement.speed, _movement.acceleration)
			vertical   = move_toward(_movement.current_velocity.y, vertical * _movement.speed, _movement.acceleration)
	else:
		if get_obeys_gravity():
			ProgramAlerts.add_error(name + " cannot obey gravity if it does not move smoothly")
		
		horizontal = horizontal * _movement.speed
		vertical   = vertical * _movement.speed
	
	if _metadata.is_looking:
		rotation = Vector2(horizontal, vertical).angle()
	
	# Perform the calculation to move the enitity
	_movement.current_velocity = move_and_slide(Vector2(horizontal, vertical), Globalsv2.ORIENTATION.FLOOR_NORMAL)

# Create a wait array instruction
func wait(duration: float) -> Array:
	return ["wait", duration]

# Cause the entity to rotate about its center
func spin(deg_per_second: float, direction: float) -> void:
	rotate(deg2rad(deg_per_second * direction))

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Try to automatically determine what direction the sprite should be facing
func _auto_facing() -> void:
	if _movement.current_velocity.x > 0.0:
		set_direction_facing(Globalsv2.DIRECTION.RIGHT)
	elif _movement.current_velocity.x < 0.0:
		set_direction_facing(Globalsv2.DIRECTION.LEFT)

# Recursively flip the entire entity horizontally to face in the last direction
func _flip_entity(parent: Node) -> void:
	for child in parent.get_children():
		if child.get_child_count() > 0:
			_flip_entity(child)
		else:
			if child is AnimatedSprite:
				child.flip_h = !child.flip_h
			elif child is Sprite:
				child.flip_h = !child.flip_h
			elif child is CollisionShape2D:
				child.position.x *= -1
			elif child is LightOccluder2D:
				for index in range(child.occluder.polygon.size()):
						child.occluder.polygon[index].x *= -1

# Move the entity in a straight line a certain distance in a certain direction, then stop
func _move_distance(movement: Dictionary) -> void:
	move_dynamically(movement.direction)
	movement.distance_remaining -= _movement.current_velocity.length() * get_physics_process_delta_time()
	movement.is_completed = movement.distance_remaining <= 0.0

# Move the entity in a straight line a certain direction for a certain amount of time
func _move_duration(movement: Dictionary) -> void:
	move_dynamically(movement.direction)
	movement.duration_remaining -= get_physics_process_delta_time()
	movement.is_completed = movement.duration_remaining <= 0.0

# Move the entity to the given point, then stop
func _move_to_point(movement: Dictionary) -> void:
	var pre_direction:  Vector2 = global_position.direction_to(movement.end_point)
	move_dynamically(pre_direction)
	movement.is_completed = global_position.distance_squared_to(movement.end_point) < _movement.speed

# Reset the data in a movement set
func _movement_reset(movement_set: Dictionary) -> void:
	if _metadata.movement.is_looping:
		movement_set.is_completed = false
		
	if movement_set.has("initial_distance"):
		movement_set.distance_remaining = movement_set.initial_distance
	elif movement_set.has("initial_duration"):
		movement_set.duration_remaining = movement_set.initial_duration

# Move to the next instruction and if looping, loop to beginning
func _next_instruction() -> void:
	_movement_reset(_metadata.movement.instructions[_metadata.movement.current_instruction])
	if _metadata.movement.current_instruction < _metadata.movement.instructions.size():
		_metadata.movement.current_instruction += 1
	
	if _metadata.movement.current_instruction >= _metadata.movement.instructions.size():
		_metadata.movement.current_instruction = 0

# Set the layer bit flags for the entity
func _set_layer_bits(layers: Array) -> void:
	# Does the entity have an Area2D collision shape
	if not has_node("Area2D/CollisionShape2D"):
		push_error("Cannot modify layers.\nEntity does not contain an Area2D/CollisionShape2D.")
		get_tree().quit(-1)
	
	for current_layer in range(32):
		set_collision_layer_bit(current_layer, false)
		$Area2D.set_collision_layer_bit(current_layer, false)
		for given_layer in range(layers.size()):
			if current_layer == layers[given_layer]:
				set_collision_layer_bit(current_layer, true)
				$Area2D.set_collision_layer_bit(current_layer, true)
				break

# Set the mask bit flags for the entity
func _set_mask_bits(masks: Array) -> void:
	# Does the entity have an Area2D collision shape
	if not has_node("Area2D/CollisionShape2D"):
		push_error("Cannot modify masks.\nEntity does not contain an Area2D/CollisionShape2D.")
		get_tree().quit(-1)
	
	for current_mask in range(32):
		set_collision_mask_bit(current_mask, false)
		$Area2D.set_collision_mask_bit(current_mask, false)
		for given_mask in range(masks.size()):
			if current_mask == masks[given_mask]:
				set_collision_mask_bit(current_mask, true)
				$Area2D.set_collision_mask_bit(current_mask, true)
				break

# Create a line in the direction of current velocity
func _show_direction() -> void:
	draw_line(Vector2.ZERO, _movement.current_velocity.normalized() * Globalsv2.ORIENTATION.TILE_SIZE, Color(255, 0, 0), 1.0, false)

# Turn an instruction into a movement set
func _to_movement_set(instruction: Array) -> Dictionary:
	var new_movement_set: Dictionary = {}
	
	new_movement_set.is_completed = false
	
	match instruction[0]:
		"distance", "dis":
			new_movement_set.direction           = instruction[1].normalized()
			new_movement_set.initial_distance    = Globalsv2.til2pix(instruction[2])
			new_movement_set.distance_remaining  = Globalsv2.til2pix(instruction[2])
		"duration", "dur":
			new_movement_set.direction          = instruction[1].normalized()
			new_movement_set.initial_duration   = instruction[2]
			new_movement_set.duration_remaining = instruction[2]
		"point", "pt":
			if instruction[1] is String:
				if instruction[1] == "sp" or instruction[1] =="spawn":
					new_movement_set.end_point = _metadata.spawn_point
			else:
				new_movement_set.end_point = instruction[1]
		"jump":
			new_movement_set.jump_height = instruction[1]
		"wait":
			new_movement_set.wait_duration = instruction[1]
			new_movement_set.wait_remaining = instruction[1]
	
	return new_movement_set

# Decrease the invulnerability duration
# Set to -1.0 for permanent invulnerability
func _update_invulnerability(delta: float) -> void:
	if _health.invulnerability_duration > 0.0:
		_health.invulnerability_duration -= delta
	elif _health.invulnerability_duration != -1.0:
		_health.invulnerability_duration = 0.0

# Updates the last direction the entity has gone
# Calculates for the vertical and horizontal directions
func _update_last_direction() -> void:
	# Horizontal Velocity is not zero
	if _movement.current_velocity.x != 0.0:
		if sign(_movement.current_velocity.x) != sign(_metadata.last_direction.x):
			_metadata.last_direction.x = sign(_movement.current_velocity.x)
	
	# Vertical Velocity is not zero
	if _movement.current_velocity.y != 0.0:
		if sign(_movement.current_velocity.y) != sign(_metadata.last_direction.y):
			_metadata.last_direction.y = sign(_movement.current_velocity.y)

# Update the time the entity has spent in the air
func _update_time_in_air(delta: float) -> void:
	if get_obeys_gravity():
		if is_on_floor():
			_metadata.time_in_air = 0.0
		else:
			_metadata.time_in_air += delta

# Update the time the entity has spent on the ground
func _update_time_on_ground(delta: float) -> void:
	if get_obeys_gravity():
		if is_on_floor():
			_metadata.time_on_ground += delta
		else:
			_metadata.time_on_ground = 0.0

# Make the entity wait for a set time
func _wait(instruction: Dictionary) -> void:
	if instruction.wait_remaining > 0.0:
		instruction.wait_remaining -= get_physics_process_delta_time()
	else:
		instruction.wait_remaining = instruction.wait_duration
		instruction.is_completed  = true

#-----------------------------------------------------------------------------#
#                           Depreciated Functions                             #
#-----------------------------------------------------------------------------#
# Create the entity, set the layers, and set the group
func create_entity(group: String) -> void:
	ProgramAlerts.add_warning("create_entity() is being depreciated")

	match group:
		Globalsv2.GROUP.COLLECTABLE:
			add_to_group   (group)
			_set_layer_bits([Globalsv2.LAYER.COLLECTABLE])
			_set_mask_bits ([Globalsv2.LAYER.PLAYER])
		Globalsv2.GROUP.ENEMY:
			add_to_group   (group)
			_set_layer_bits([Globalsv2.LAYER.ENEMY])
			_set_mask_bits ([Globalsv2.LAYER.PLAYER, Globalsv2.LAYER.ENEMY, Globalsv2.LAYER.WORLD])
		Globalsv2.GROUP.INTERACTABLE:
			add_to_group   (group)
			_set_layer_bits([Globalsv2.LAYER.INTERACTABLE])
			_set_mask_bits ([Globalsv2.LAYER.PLAYER])
		Globalsv2.GROUP.PLAYER:
			add_to_group   (group)
			_set_layer_bits([Globalsv2.LAYER.PLAYER])
			_set_mask_bits ([Globalsv2.LAYER.ENEMY, Globalsv2.LAYER.COLLECTABLE, Globalsv2.LAYER.INTERACTABLE, Globalsv2.LAYER.WORLD])
		Globalsv2.GROUP.PROJECTILE:
			add_to_group   (group)
			_set_layer_bits([Globalsv2.LAYER.PROJECTILE])
			_set_mask_bits ([Globalsv2.LAYER.WORLD])
		_:
			push_error(group + " is not a valid group")
			get_tree().quit()

# Check to see that movements are formmated correctly
func _check_movements(movements: Array) -> void:
	ProgramAlerts.add_warning("_check_movements() is being depreciated")
	for instruction in movements:
		if not (instruction[0] is Vector2):
			ProgramAlerts.add_error("Each instruction needs to have [direction/endpoint: Vector2, distance/duration: float]")
		if not (instruction[1] is float):
			ProgramAlerts.add_error("Each instruction needs to have [direction/endpoint: Vector2, distance/duration: float]")
