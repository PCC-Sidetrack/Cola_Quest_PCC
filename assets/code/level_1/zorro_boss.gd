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
export var health:          int   = 30

#-----------------------------------------------------------------------------#
#                               Public Variables                              #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#
# Holds the positionary nodes for the boss fight
onready var _nodes: Dictionary = {
		start_point = self.get_node("boss_movement_points/boss_fight/start_point")
	}

# Instruction set for the first stage of the boss fight
onready var _stage1_instructions: Array = [
		end_point(_nodes.start_point.global_position),
		duration(Vector2.LEFT, 2.0),
	]
	
# Instruction set for the second stage of the boss fight
onready var _stage2_instructions: Array = [
		
	]
	
# Instruction set for the third stage of the boss fight
onready var _stage3_instructions: Array = [
		
	]
	
	
#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Set the instructions set for zorro's ai
	initialize_instructions(_stage1_instructions, true)
	
	# Initialize zorro as an enemy
	initialize_enemy(health, damage, speed, acceleration, jump_velocity, obeys_gravity, smooth_movement)
	set_auto_facing(true)

	_change_animation("walk_sword")
	
# Runs every physics engine update
func _physics_process(delta) -> void:
	move()

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#


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
	else:
		$sprites.get_node(corresponding_sprite).visible = true
	
	$AnimationPlayer.play(animation)

#-----------------------------------------------------------------------------#
#                                Trigger Methods                              #
#-----------------------------------------------------------------------------#
# Triggered whenever an instruction is executed by the entity
# NOTE: Name is given automatically from the INSTRUCTIONS dictionary when each
#       instruction is created using the initialize_instruction() method.
#       The id can be specified as the last parameter of any instruction (such
#       as in _stage1_instructions methods) or left blank. I left blank, ids
#       will be assigned increasingly starting at 0 in the order that the
#       initial instructions were specified.
func _on_zorro_boss_instruction_executed(name, id):
	match name:
		INSTRUCTIONS.MOVE_DISTANCE:
			_change_animation("walk_sword")
		INSTRUCTIONS.WAIT:
			_change_animation("idle_sword")
		INSTRUCTIONS.NONE:
			_change_animation("idle_sword")
