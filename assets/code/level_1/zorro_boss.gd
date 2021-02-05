#-----------------------------------------------------------------------------#
# Class Name:   zorro_boss.gd
# Description:  AI for the zorro boss entity in level 1
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: December 10, 2020
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                              Private Constants                              #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Controls whether zorro obeys gravity
export var obeys_gravity:   bool  = true
# Controls whether zorro accelerates into movement or not
export var smooth_movement: bool  = true

# Controls the acceleration of movement if smooth_movement is turned on
export var acceleration:    float = 20.0
# Speed at which zorro jumps
export var jump_velocity:   float = 1.0
# Speed at which zorro moves
export var speed:           float = 4.0

# Damage that zorro deals to entitys
export var damage:          int   = 1
# Amount of damage zorro can take before dying
export var health:          int   = 16

#-----------------------------------------------------------------------------#
#                               Public Variables                              #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Tracks the current stage of the boss fight
var _current_stage:  int = 1
# Health amount to activate stage two at
var _stage_two_hp:   int = health - (health / 4)
# Health amount to activate stage three at
var _stage_three_hp: int = _stage_two_hp - (_stage_two_hp / 2)
# Health amount to run away at
var _run_away_hp:    int = 3

# Tracks whether the boss fight is on-going
var _fight_started:  bool = false
# Tracks whether the sprite is currently flipped to the left
var _sprite_flipped: bool = false

# Current movement direction
var _h_direction: Vector2 = Vector2.LEFT

# Saves the name of the current sprite being shown
var _current_sprite: String = ""

#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#
# Holds the positionary nodes for the boss fight
onready var _nodes: Dictionary = {
		start_point = self.get_node("boss_movement_points/boss_fight/start_point")
	}
	
	
#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialize zorro as an enemy
	initialize_enemy(health, damage, speed, acceleration, jump_velocity, obeys_gravity, smooth_movement)
	# Note: because the entiy has a collision shape for the sword, automatically
	#       flipping the entity will glitch the entity into the wall
	set_auto_facing(false)
	set_direction_facing(Globals.DIRECTION.LEFT)
	# flip the entity to make sure it's facing the correct direction
	_flip()
	_change_animation("draw_sword", "draw_sword")
	
# Runs every physics engine update
func _physics_process(_delta: float) -> void:
	# Flip the entity if needed
	if _h_direction == Vector2.RIGHT and !_sprite_flipped:
		_flip()
	elif _h_direction == Vector2.LEFT and _sprite_flipped:
		_flip()
	
	# Check the boss's health level to see if the next stage should begin
	if get_current_health() <= _stage_two_hp && _current_stage == 1:
		_current_stage = 2
		_steal_health_protocol()
	elif get_current_health() <= _stage_three_hp && _current_stage == 2:
		_current_stage = 3
	elif get_current_health() <= _run_away_hp:
		_run_away_protocol()
	
	# Check which stage instructions should be executed
	if _current_stage == 2:
		_run_stage_two_ai()
	elif _current_stage == 3:
		_run_stage_three_ai()
	else:
		_run_stage_one_ai()
		

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
# Setter and Getter Methods
func get_fight_started() -> bool: return _fight_started


#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#
# Change the animation of the sprite
func _change_animation(animation: String, corresponding_sprite: String = "") -> void:
	# First set all the sprites to invisible
	for sprite in $sprites.get_children():
		if sprite.visible == true:
			sprite.visible = false
	
	# Set the correct sprite to visible and play the animation
	if corresponding_sprite == "":
		$sprites.get_node(animation).visible = true
		_current_sprite = animation
	else:
		$sprites.get_node(corresponding_sprite).visible = true
		_current_sprite = corresponding_sprite
	
	$AnimationPlayer.play(animation)
	
# Flip the zorro entity. Can't use entity code because it doesn't properly
# flip the sword
func _flip() -> void:
	# Store the current sprite for later use
	var current_sprite = $sprites.get_node(_current_sprite)
	
	# Flip all dr. geary sprites
	for child in get_node("sprites").get_children():
		if child is Sprite:
			child.flip_h = !child.flip_h
				
	# Flip the sword sprite and collision shape
	$sword/Sprite.scale *= -1
	$sword/CollisionShape2D.scale.x *= -1
	
	if _sprite_flipped:
		$sword/Sprite.rotation_degrees = $sword.rotation_degrees
		$sword/CollisionShape2D.rotation_degrees = $sword.rotation_degrees
		
		$sword/Sprite.position.x -= $sprites.global_position.x - $sword/Sprite.global_position.x
		
		# Calculate the position to move the sword to (based on the position
		# of the current sprite's globol position)
		#if current_sprite is Sprite:
			#center_curr_sprite = current_sprite.global_position.x + (current_sprite.texture.get_size().x / (2 * current_sprite.hframes)) * current_sprite.scale.x
			#center_sword       = $sword/Sprite.global_position.x  + ($sword/Sprite.texture.get_size().x) * $sword.scale.x
			
			##$sword/Sprite.global_position.x += current_sprite.global_position.x + (current_sprite.texture.get_size().x / (2 * current_sprite.hframes)) - $sword/Sprite.global_position.x
			#$sword/Sprite.global_position.x += (center_curr_sprite - center_sword)
			#$sword/Sprite.position.x -= (current_sprite.global_position.x - $sword/Sprite.global_position.x)
	else:
		$sword/Sprite.rotation_degrees = 0
		$sword/Sprite.position = Vector2(0, 0)
		$sword/CollisionShape2D.rotation_degrees = 0
		$sword/CollisionShape2D.position = Vector2(0, 0)
	
	# Remember that the sprite is flipped to the right
	_sprite_flipped = !_sprite_flipped
				
	
# Instructions for the first stage of the boss fight
func _run_stage_one_ai() -> void:
	# STAGE ONE INSTRUCTIONS:
	# Move left and right (bouncing off the wall) until near the player's x value
	# If player's y value is within a range of enemy's own y value, then perform
	# a sword attack.
	# If not, check if inside a scaffolding area. If inside scaffolding area, jump up
	# and check again at the top of the jump for the x and y locations. Repeat top steps
	# until close to the player. When y value and x value are close to the player, make
	# a sword attack.
	
	# Lock the character movement for a moment while Dr. Geary appears.
	
	#_change_animation("")
	move_dynamically(_h_direction)
	
	if is_on_wall():
		_h_direction = -_h_direction
	
	
# Instructions for the second stage of the boss fight
func _run_stage_two_ai() -> void:
	# STAGE TWO INSTRUCTIONS:
	# Steal some of the player's hp (one hit point which will translate to 3 for him)
	# Spawn in some moving drones to make the parkour more difficult for the player.
	# Move left and right trying to avoid the player, stopping every once in a while
	# to play the taunting animation.
	# If in a place to jump on the scaffolding, then make a random decision to do so
	# or not.
	# Stop every once in a while and throw a 3x5 card at the player.
	pass
	
# Instructions for the thrid stage of the boss fight
func _run_stage_three_ai() -> void:
	# STAGE THREE INSTRUCTIONS:
	# If drone's aren't still there, respawn them. Also spawn in a few 3x5 shooting
	# drones.
	# Combine the ai from stages one and two so that Dr. Geary is trying to 
	# attack with the sword and occasionally throw's 3x5 cards as well.
	pass
	
# Steals health from the player, adds a multiplier, and adds it to the boss hp
func _steal_health_protocol() -> void:
	pass
	
# Causes the game to freeze while the boss escapes
func _run_away_protocol() -> void:
	pass

#-----------------------------------------------------------------------------#
#                                Trigger Methods                              #
#-----------------------------------------------------------------------------#
# Deal damage to the player if the entity collides with it
func _on_zorro_boss_collision(body) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
