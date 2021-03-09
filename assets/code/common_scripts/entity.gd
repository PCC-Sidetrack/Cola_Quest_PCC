#-----------------------------------------------------------------------------#
# File Name:   entity.gd
# Description: The basic physics and class methods for any entity in each level
# Author:      Jeff Newell (mostly) & Andrew Zedwick
# Company:     Sidetrack
# Date:        November 8, 2020
#-----------------------------------------------------------------------------#

class_name Entity
extends    KinematicBody2D

# An entity is any object that moves and interacts with the terrain
# An entity will have damage, health, and movement

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Emitted whenever the entity's health is changed
signal health_changed(ammount)
# Emitted whenever they entity's health falls to zero or below
signal death()
# Emitted whenever the entity collides with something
signal collision(body)
# Emitted whenever an AI instruction set is executed
signal instruction_executed(name, id)

#-----------------------------------------------------------------------------#
#                               Public Constants                              #
#-----------------------------------------------------------------------------#
# Holds the names for various AI instructions
const INSTRUCTIONS: Dictionary = {
	MOVE_DISTANCE = "distance",
	MOVE_DURATION = "duration",
	MOVE_TO_POINT = "end_point",
	JUMP          = "jump",
	WAIT          = "wait",
	NONE          = "none",
}

#-----------------------------------------------------------------------------#
#                              Private Variables                              #
#-----------------------------------------------------------------------------#
# The damage the entity does
var _damage: Dictionary = {
	amount               = 0,
	knockback_multiplier = 1.0,
}

# Health data for the entity
var _health: Dictionary = {
	current                  = 1,
	invulnerability_duration = 0.0,
	maximum                  = 1,
}

# The movement information for the entity
var _movement: Dictionary = {
	acceleration          = 10.0,
	current_velocity      = Vector2.ZERO,
	#gravity               = 0.0,
	initial_jump_velocity = 0.0,
	speed                 = 0.0,
}

# Different metadata to track for the entity
var _metadata: Dictionary = {
	auto_facing         = false,
	debug               = false,
	direction_facing    = Globals.DIRECTION.RIGHT,
	is_looking          = false,
	is_movement_smooth  = true,
	last_direction      = Vector2(Globals.DIRECTION.RIGHT, Globals.DIRECTION.UP),
	life_time           = -1.0,
	movement            = {
		current_instruction = 0,
		prev_instruction    = -1,
		used_ids            = [-1],
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
func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)
	_update_last_direction ()
	_update_life_time      (delta)
	_update_time_in_air    (delta)
	_update_time_on_ground (delta)
	update()

func _draw() -> void:
	if _metadata.debug:
		_show_direction()

#-----------------------------------------------------------------------------#
#                             Getter Functions                                #
#-----------------------------------------------------------------------------#
func get_auto_facing() -> bool:
	return _metadata.auto_facing
func get_current_instruction  () -> int:
	return _metadata.movement.current_instruction
func get_current_instruction_name() -> String:
	var name: String = INSTRUCTIONS.NONE
	if _metadata.movement.instructions != {}:
		name = _metadata.movement.instructions[_metadata.movement.current_instruction].name
	return name
func get_current_instruction_id() -> int:
	var id: int = -1
	if _metadata.movement.instructions != {}:
		id = _metadata.movement.instructions[_metadata.movement.current_instruction].id
	return id
func get_current_health       () -> int:
	return round(_health.current) as int
func get_current_velocity     () -> Vector2:
	return _movement.current_velocity
func get_collision_box_size   () -> Vector2:
	if has_node("Area2D/CollisionShape2D"):
		return get_node("Area2D/CollisionShape2D").get_shape().extents
	else:
		return Vector2(0.0, 0.0)
func get_damage               () -> int:
	return round(_damage.amount) as int
func get_direction_facing     () -> float:
	return _metadata.direction_facing
func get_invulnerability      () -> bool:
	return _health.invulnerability_duration > 0.0
func get_last_direction       () -> Vector2:
	return _metadata.last_direction
func get_prev_instruction_name() -> String:
	var name: String = INSTRUCTIONS.NONE
	if _metadata.movement.instructions != {}:
		name = _metadata.movement.instructions[_metadata.movement.prev_instruction].name
	return name
func get_prev_instruction_id() -> int:
	var id: int = -1
	if _metadata.movement.instructions != {} and _metadata.movement.prev_instruction >= 0:
		id = _metadata.movement.instructions[_metadata.movement.prev_instruction].id
	return id
func get_max_health           () -> int:
	return round(_health.maximum) as int
func get_spawn_point          () -> Vector2:
	return _metadata.spawn_point
#func get_obeys_gravity       () -> bool:
#	return _movement.gravity > 0.0
func get_obeys_gravity        () -> bool:
	return _metadata.obeys_gravity
func get_position             () -> Vector2:
	return global_position
func get_speed                () -> float:
	return _movement.speed
func get_time_in_air          () -> float:
	return _metadata.time_in_air
func get_time_in_direction    () -> Vector2:
	return _metadata.time_in_direction
func get_time_on_ground       () -> float:
	return _metadata.time_on_ground
func get_knockback_multiplier () -> float:
	return _damage.knockback_multiplier
func get_jump_speed           () -> float:
	return _movement.initial_jump_velocity

#-----------------------------------------------------------------------------#
#                             Setter Functions                                #
#-----------------------------------------------------------------------------#
func set_acceleration           (new_rate: float) -> void:
	_movement.acceleration = new_rate
func set_auto_facing            (is_auto_facing: bool) -> void:
	_metadata.auto_facing = is_auto_facing
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
#	_movement.gravity               = Globals.til2pix(new_jump_height) / new_jump_time
#	_movement.initial_jump_velocity = sqrt(2 * _movement.gravity * Globals.til2pix(new_jump_height))
func set_jump                   (velocity: float) -> void:
	_movement.initial_jump_velocity = velocity
func set_knockback_multiplier   (new_multiplier: float) -> void:
	_damage.knockback_multiplier = new_multiplier
func set_life_time              (new_life_time: float) -> void:
	_metadata.life_time = new_life_time
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
	_movement.speed = Globals.til2pix(new_movement_speed)
func set_velocity               (new_velocity: Vector2) -> void:
	_movement.current_velocity = new_velocity

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Deal damage to another entity
func deal_damage(other_entity: Entity) -> void:
	# Variable to save on method calls, holds the other entity's current health
	var other_entity_health = other_entity.get_current_health()
	# Holds the amount of damage that is being applied to the other entity
	var damage_applied: int = _damage.amount
		
	# Only take damage if damage is not negative and player is not invulnerable
	if _damage.amount > 0 and !other_entity.get_invulnerability():
		if other_entity_health - _damage.amount >= 0:
			other_entity._set_health(other_entity_health - _damage.amount)
		# If the damage applied brings the entity's health below 0, set it to 0
		else:
			damage_applied = other_entity_health
			other_entity._set_health(0)
		
		other_entity.emit_signal("health_changed", -damage_applied)	
		
	# If the damage is negative, then heal the other entity
	elif _damage.amount < 0:
		if other_entity_health - _damage.amount <= other_entity.get_max_health():
			other_entity._set_health(other_entity_health - _damage.amount)
		# If damage applied brings the entity's health above max, set it to max
		else:
			damage_applied = other_entity_health - other_entity.get_max_health()
			other_entity._set_health(other_entity.get_max_health())
			
		other_entity.emit_signal("health_changed", -damage_applied)
	
	# Check if the entity has died. If it has, call on_death()
	if other_entity.get_current_health() <= 0:
		other_entity.emit_signal("death")

# Take damage from another entity (or heal if the damage is negative)
func take_damage(damage: int) -> void:
	# Only take damage if damage is not negative and player is not invulnerable
	if damage > 0 and !get_invulnerability():
		if _health.current - damage >= 0:
			_health.current -= damage
		else:
			damage = _health.current
			_health.current = 0
			
		emit_signal("health_changed", -damage)
			
	# If damage is negative, then heal the player
	elif damage < 0:
		if _health.current - damage <= _health.maximum:
			_health.current -= damage
		else:
			damage = _health.current - _health.maximum
			_health.current = _health.maximum
			
		emit_signal("health_changed", -damage)
	
	# If entity is dead, emit a death trigger
	if _health.current <= 0:
		emit_signal("death")
		
func set_current_health(new_health: int) -> void:
	# Holds the health change. Health is only changed up to the max and min
	# allowed values.
	var health_change: int = new_health
	
	# Change the health of the entity
	if new_health >= 0 and new_health <= _health.maximum:
		_health.current = new_health
	elif new_health < 0:
		health_change   = -_health.current
		_health.current = 0
	elif new_health > _health.maximum:
		health_change   = _health.maximum - _health.current
		_health.current = _health.maximum
		
	# If health was changed, emit a health changed trigger
	if health_change != 0:
		emit_signal("health_changed", health_change)
	
	# If entity is dead, emit a death trigger
	if _health.current <= 0:
		emit_signal("death")
		
	
		
# Sets the entity's health to 0 and emits a kill and health changed signal
func kill() -> void:
	# Holds the last health for use in emitting a health changed signal
	# Commented out below line until "last_health" is used, to avoid errors
	#var last_health: int = _health.current
	
	take_damage(_health.current)

# Delete the entity
func delete() -> void:
	# Delete the entity
	queue_free()

# Initialize a collectable entity
func initialize_collectable() -> void:
	add_to_group   (Globals.GROUP.COLLECTABLE)
	add_to_group   (Globals.GROUP.ENTITY)
	_set_layer_bits([Globals.LAYER.COLLECTABLE])
	_set_mask_bits ([Globals.LAYER.PLAYER])

# Initialize an enemy entity
#func initialize_enemy(health: int, damage: int, speed: float, acceleration: float = 20.0, jump_height:float = 0.0, jump_duration: float = 1.0, smooth_movement: bool = true) -> void:
func initialize_enemy(health: int, damage: int, speed: float, acceleration: float = 20.0, jump_velocity: float = 1.0, obeys_gravity: bool = false, smooth_movement: bool = true) -> void:
	add_to_group       (Globals.GROUP.ENEMY)
	add_to_group       (Globals.GROUP.ENTITY)
	_set_layer_bits    ([Globals.LAYER.ENEMY])
	_set_mask_bits     ([Globals.LAYER.PLAYER, Globals.LAYER.WORLD])
	set_acceleration   (acceleration)
	set_damage         (damage)
	#set_jump           (jump_height, jump_duration)
	set_jump           (jump_velocity)
	set_max_health     (health)
	set_obeys_gravity  (obeys_gravity)
	set_smooth_movement(smooth_movement)
	set_speed          (speed)
	
	_health.current = health

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
	add_to_group       (Globals.GROUP.PLAYER)
	add_to_group       (Globals.GROUP.ENTITY)
	_set_layer_bits    ([Globals.LAYER.PLAYER])
	_set_mask_bits     ([Globals.LAYER.ENEMY, Globals.LAYER.COLLECTABLE, Globals.LAYER.INTERACTABLE, Globals.LAYER.WORLD, Globals.LAYER.SPAWNPOINT])
	set_acceleration   (acceleration)
	set_damage         (damage)
	set_max_health     (health)
	set_obeys_gravity  (obeys_gravity)
	#set_jump           (jump_height, jump_duration)
	set_jump           (jump_velocity)
	set_smooth_movement(smooth_movement)
	set_speed          (speed)
	
	_health.current = health

# Initialize a projectile entity
func initialize_projectile(damage: int, speed: float, initiator: String, direction: Vector2 = Vector2.RIGHT, turn_force: float = 1.0, life_time: float = -1.0) -> void:
	add_to_group       (Globals.GROUP.PROJECTILE)
	add_to_group       (Globals.GROUP.ENTITY)
	_set_layer_bits    ([Globals.LAYER.PROJECTILE])
	_set_mask_bits     ([Globals.LAYER.WORLD, Globals.LAYER.PLAYER])
	set_acceleration   (turn_force)
	set_damage         (damage)
	set_life_time      (life_time)
	set_speed          (speed)
	set_velocity       (direction)
	
	match initiator:
		"player", "p":
			add_to_group(Globals.GROUP.PLAYER)
		"enemy", "e":
			add_to_group(Globals.GROUP.ENEMY)

# Cause the entity to jump
func jump(height: float = 1.0) -> void:
	if height > 1.0 or height <= 0.0:
		ProgramAlerts.add_warning("jump height should normally be between 1.0 and greater than 0.0")

	_movement.current_velocity.y = _movement.initial_jump_velocity * -height

# Cause the entity that calls this function to knockback based off of the entity's speed and the referenced entity's damage
func knockback(other_entity: Object, direction: Vector2 = Vector2(0.0, 0.0)) -> void:
	if direction == Vector2(0.0, 0.0):
		set_velocity(other_entity.get_position().direction_to(global_position).normalized() * (get_speed() * other_entity.get_knockback_multiplier() * 2.0))
	else:
		set_velocity(direction * (get_speed() * other_entity.get_knockback_multiplier() * 2.0))

# A generic move function that determines what kind of movement the entity contains
# This is intended for more automation, but should not be considered lazy coding
# Provides minimal control over entities
# Returns whether the entity has moved
func move() -> void:
	var current_instruction: Dictionary = _metadata.movement.instructions[_metadata.movement.current_instruction]
	
	if _metadata.auto_facing:
		_auto_facing()
	
	if not current_instruction.is_completed:
		match current_instruction.name:
			INSTRUCTIONS.MOVE_DISTANCE:
				_move_distance(current_instruction)
			INSTRUCTIONS.MOVE_DURATION:
				_move_duration(current_instruction)
			INSTRUCTIONS.MOVE_TO_POINT:
				_move_to_point(current_instruction)
			INSTRUCTIONS.JUMP:
				jump(current_instruction.jump_height)
			INSTRUCTIONS.WAIT:
				_wait(current_instruction)
				
		# If the instruction id has changed since the last instruction, emit a signal
		if get_current_instruction_id() != get_prev_instruction_id():
			emit_signal("instruction_executed", current_instruction.name, current_instruction.id)
	
		
		# Set the previous instruction executed to the current instruction
		_metadata.movement.prev_instruction = _metadata.movement.current_instruction
	
	if current_instruction.is_completed:
		_next_instruction()

# Move based on a dynamically changing horizontal direction
# Provides the finest control of entities
func move_dynamically(direction: Vector2, custom_acceleration: float = _movement.acceleration) -> void:
	# Normalize the direction vector to reduce it to purely a direction and not a magnitude
	var horizontal: float = direction.normalized().x
	var vertical:   float = direction.normalized().y
	
	if _metadata.auto_facing:
		_auto_facing()
	
	# Determine what kind of movement is being used
	# NOTE:
	#  - Entities that obey gravity must move smoothy
	#  - Entities cannot obey gravity if they do not move smoothly
	if _metadata.is_movement_smooth:
		if get_obeys_gravity():
			horizontal = move_toward(_movement.current_velocity.x, horizontal * _movement.speed, custom_acceleration)
			vertical   = move_toward(_movement.current_velocity.y, Globals.ORIENTATION.MAX_FALL_SPEED, Globals.ORIENTATION.MAX_FALL_SPEED * get_physics_process_delta_time())
		else:
			horizontal = move_toward(_movement.current_velocity.x, horizontal * _movement.speed, custom_acceleration)
			vertical   = move_toward(_movement.current_velocity.y, vertical * _movement.speed, custom_acceleration)
	else:
		if get_obeys_gravity():
			ProgramAlerts.add_error(name + " cannot obey gravity if it does not move smoothly")
		
		horizontal = horizontal * _movement.speed
		vertical   = vertical   * _movement.speed
	
	if _metadata.is_looking:
		rotation = Vector2(horizontal, vertical).angle()
	
	# Perform the calculation to move the enitity and save the collision data	
	_movement.current_velocity = move_and_slide(Vector2(horizontal, vertical), Globals.ORIENTATION.FLOOR_NORMAL)
	
	# If a collision occured, call on_collision for the last one that happened during the movement
	var slide_count: int = get_slide_count()
	if slide_count > 0:
		emit_signal("collision", get_slide_collision(slide_count - 1).collider)

# Cause the entity to rotate about its center
func spin(deg_per_second: float, direction: float) -> void:
	rotate(deg2rad(deg_per_second * direction))
	
#-----------------------------------------------------------------------------#
#                         AI Instruction Set Methods                          #
#-----------------------------------------------------------------------------#

# Create a distance array instruction - used to move a certain distance
func distance(direction: Vector2, distance: float, instr_id = -1) -> Array:
	return [INSTRUCTIONS.MOVE_DISTANCE, instr_id, direction, distance]

# Create a duration array instruction - used to move in a direction for a duration
func duration(direction: Vector2, duration: float, instr_id: int = -1) -> Array:
	return[INSTRUCTIONS.MOVE_DURATION, instr_id, direction, duration]

# Create an end point array instruction - used to move to a specific point
func end_point(destination: Vector2, instr_id: int = -1) -> Array:
	return [INSTRUCTIONS.MOVE_TO_POINT, instr_id, destination]

# Moves to the entity's spawn point (usually where it was first placed in the level)
func move_to_spawn(instr_id: int = -1) -> Array:
	return [INSTRUCTIONS.MOVE_TO_POINT, instr_id, "spawn"]
	
# Create a jump array instruction - used to cause an entity to jump
func jump_inst(height: float, instr_id: int = -1) -> Array:
	return [INSTRUCTIONS.JUMP, instr_id, height]
	
# Create a wait array instruction - used to cause an entity to wait
func wait(duration: float, instr_id: int = 0) -> Array:
	return [INSTRUCTIONS.WAIT, instr_id, duration]

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Try to automatically determine what direction the sprite should be facing
func _auto_facing() -> void:
	if _movement.current_velocity.x > 0.0:
		set_direction_facing(Globals.DIRECTION.RIGHT)
	elif _movement.current_velocity.x < 0.0:
		set_direction_facing(Globals.DIRECTION.LEFT)

# Recursively flip the entire entity horizontally to face in the last direction
func _flip_entity(parent: Node) -> void:
	for child in parent.get_children():
		if child.get_child_count() > 0 and not (child is Control):
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
	
	# Move the current instruction to the next instruction
	if _metadata.movement.current_instruction < _metadata.movement.instructions.size():
		_metadata.movement.current_instruction += 1
	
	if _metadata.movement.current_instruction >= _metadata.movement.instructions.size():
		_metadata.movement.current_instruction = 0

# Directly sets the health bar to a value. Doesn't trigger any updates (such
# as GUI)
func _set_health         (new_health: int) -> void:
	if new_health <= _health.maximum and new_health >= 0:
		_health.current = new_health
	elif new_health < 0:
		_health.current = 0
	elif new_health > _health.maximum:
		_health.current = _health.maximum

# Set the layer bit flags for the entity
func _set_layer_bits(layers: Array) -> void:
	# Does the entity have an Area2D collision shape
	#if not has_node("Area2D/CollisionShape2D"):
		#push_error("Cannot modify layers.\nEntity does not contain an Area2D/CollisionShape2D.")
		#get_tree().quit(-1)
	
	for current_layer in range(32):
		set_collision_layer_bit(current_layer, false)
		#$Area2D.set_collision_layer_bit(current_layer, false)
		for given_layer in range(layers.size()):
			if current_layer == layers[given_layer]:
				set_collision_layer_bit(current_layer, true)
				#$Area2D.set_collision_layer_bit(current_layer, true)
				break

# Set the mask bit flags for the entity
func _set_mask_bits(masks: Array) -> void:
	# Does the entity have an Area2D collision shape
	#if not has_node("Area2D/CollisionShape2D"):
		#push_error("Cannot modify masks.\nEntity does not contain an Area2D/CollisionShape2D.")
		#get_tree().quit(-1)
	
	for current_mask in range(32):
		set_collision_mask_bit(current_mask, false)
		#$Area2D.set_collision_mask_bit(current_mask, false)
		for given_mask in range(masks.size()):
			if current_mask == masks[given_mask]:
				set_collision_mask_bit(current_mask, true)
				#$Area2D.set_collision_mask_bit(current_mask, true)
				break

# Create a line in the direction of current velocity
func _show_direction() -> void:
	draw_line(Vector2.ZERO, _movement.current_velocity.normalized() * Globals.ORIENTATION.TILE_SIZE, Color(255, 0, 0), 1.0, false)

# Turn an instruction into a movement set
func _to_movement_set(instruction: Array) -> Dictionary:
	var new_movement_set: Dictionary = {}
	var used_ids:         Array      = _metadata.movement.used_ids
	
	new_movement_set.is_completed = false
	
	# Set the name and id for the instruction (which is set for every instruction
	new_movement_set.name = instruction[0]
	
	# If the id given is -1, then pick the next unused id number (autogenerating an id)
	if instruction[1] == -1:
		var new_id: int     = used_ids[used_ids.size() - 1] + 1
		new_movement_set.id = new_id
		used_ids.append(new_id)
	else:
		# Check that the id given is not already used. If it is, issue a warning
		if instruction[1] in used_ids:
			ProgramAlerts.add_warning("The given instruction id (" + instruction[1].to_string() + ") is already being used. This could cause issues in differentiating between ai instructions.")
		
		new_movement_set.id   = instruction[1]
	
	match instruction[0]:
		INSTRUCTIONS.MOVE_DISTANCE:
			new_movement_set.direction           = instruction[2].normalized()
			new_movement_set.initial_distance    = Globals.til2pix(instruction[3])
			new_movement_set.distance_remaining  = Globals.til2pix(instruction[3])
		INSTRUCTIONS.MOVE_DURATION:
			new_movement_set.direction          = instruction[2].normalized()
			new_movement_set.initial_duration   = instruction[3]
			new_movement_set.duration_remaining = instruction[3]
		INSTRUCTIONS.MOVE_TO_POINT:
			if instruction[2] is String:
				if instruction[2] == "sp" or instruction[2] =="spawn":
					new_movement_set.end_point = _metadata.spawn_point
			else:
				new_movement_set.end_point = instruction[2]
		INSTRUCTIONS.JUMP:
			new_movement_set.jump_height = instruction[2]
		INSTRUCTIONS.WAIT:
			new_movement_set.wait_duration  = instruction[2]
			new_movement_set.wait_remaining = instruction[2]
	
	return new_movement_set

# Decrease the invulnerability duration
func _update_invulnerability(delta: float) -> void:
	if _health.invulnerability_duration > 0.0:
		_health.invulnerability_duration -= delta

# Update the life time of an entity, then deletes it when it reaches 0
# Set to -1.0 for permanent life time
func _update_life_time(delta: float) -> void:
	if _metadata.life_time != -1.0:
		if _metadata.life_time > 0.0:
			_metadata.life_time -= delta
		else:
			self.delete()

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
		Globals.GROUP.COLLECTABLE:
			add_to_group   (group)
			_set_layer_bits([Globals.LAYER.COLLECTABLE])
			_set_mask_bits ([Globals.LAYER.PLAYER])
		Globals.GROUP.ENEMY:
			add_to_group   (group)
			_set_layer_bits([Globals.LAYER.ENEMY])
			_set_mask_bits ([Globals.LAYER.PLAYER, Globals.LAYER.ENEMY, Globals.LAYER.WORLD])
		Globals.GROUP.INTERACTABLE:
			add_to_group   (group)
			_set_layer_bits([Globals.LAYER.INTERACTABLE])
			_set_mask_bits ([Globals.LAYER.PLAYER])
		Globals.GROUP.PLAYER:
			add_to_group   (group)
			_set_layer_bits([Globals.LAYER.PLAYER])
			_set_mask_bits ([Globals.LAYER.ENEMY, Globals.LAYER.COLLECTABLE, Globals.LAYER.INTERACTABLE, Globals.LAYER.WORLD])
		Globals.GROUP.PROJECTILE:
			add_to_group   (group)
			_set_layer_bits([Globals.LAYER.PROJECTILE])
			_set_mask_bits ([Globals.LAYER.WORLD])
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

# Cause another entity to be knocked back
# Based on the location of the entity in relation to the entity it is knocking back
func _knockback_old(other_entity: KinematicBody2D) -> void:
	other_entity.set_velocity(global_position.direction_to(other_entity.get_position()).normalized() * other_entity.get_speed() * _damage.knockback_multiplier)

# Flash a sprite when it takes damage
func flash_damaged():
	var t = Timer.new()
	
	t.set_wait_time(.03)
	t.set_one_shot(true)
	self.add_child(t)
	
	while get_invulnerability():
		t.start()
		yield(t, "timeout")
		set_modulate(Color(1, 0.3, 0.3, 0.3))
		t.start()
		yield(t, "timeout")
		set_modulate(Color(1, 1, 1, .5))
		
	set_modulate(Color(1, 1, 1, 1))

# Cause a sprite to flash red then fade out when it dies
func death_anim():
	var j = 1.0
	var t = Timer.new()
	
	t.set_wait_time(.03)
	t.set_one_shot(true)
	self.add_child(t)
	
	while j > 0:
		t.start()
		yield(t, "timeout")
		set_modulate(Color(1, 0.3, 0.3, j))
		j -= 0.1
