#-----------------------------------------------------------------------------#
# Class Name:   zorro_ai
# Description:  Holds the code used to control the ai for the Zorro boss.
#               Also holds comments to give an understanding of using the AI class
#               that this code inherits.
# Author:       AUTH HERE
# Company:      Sidetrack
# Last Updated: DATE HERE
#-----------------------------------------------------------------------------#

extends AI

#-----------------------------------------------------------------------------#
#                              Private Constants                              #
#-----------------------------------------------------------------------------#
#=============================
# Dictionaries
#=============================

# Enums for animations - Array Structure: [animation_name, corresponding_sprite_name]
var _ANIMATION: Dictionary = {
	IDLE          = ["idle_sword", "idle"],
	IDLE_NO_SWORD = ["idle_no_sword", "idle"],
	ARM_WAVE      = ["arm_wave", "arm_wave"],
	DRAW_SWORD    = ["draw_sword", "draw_sword"],
	SHEATH_SWORD  = ["sheath_sword", "draw_sword"],
	JUMP          = ["jump_sword", "jump"],
	JUMP_NO_SWORD = ["jump_no_sword", "jump"],
	ATTACK        = ["sword_attack", "sword_attack"],
	THROW         = ["throw", "throw"],
	WALK          = ["walk_sword", "walk"],
	WALK_NO_SWORD = ["walk_no_sword", "walk"]
}

#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Controls whether zorro obeys gravity
export var obeys_gravity:   bool  = true
# Controls whether zorro accelerates into movement or not
export var smooth_movement: bool  = true
# Controls whether zorro uses entity.gd's auto facing or custom code
export var auto_facing:     bool  = false

# Controls the acceleration of movement if smooth_movement is turned on
export var acceleration:    float = 20.0
# Speed at which zorro jumps
export var jump_speed:      float = 850.0
# Speed at which zorro moves
export var speed:           float = 5.0
# Multiplier applied to speed for dashing
export var dash_multiplier: float = 3.0

# Indicates the cooldown for attacking (in seconds)
export var attack_cooldown: float = 1.0
# Indicates the cooldown for dashing (in seconds)
# Should be same as or less than attack cooldown if used in an attack action
export var dash_cooldown:   float = attack_cooldown

# Damage that zorro deals to entitys
export var damage:                        int = 1
# Max health of boss
export var max_health:                    int = 16
# Distance of boss from player before an action occurs (such as an attack)
export var standard_distance_from_player: int = 130

#-----------------------------------------------------------------------------#
#                               Public Variables                              #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
#=============================
# Strings
#=============================

# Holds the current animation being shown
var _current_animation: Array = _ANIMATION.IDLE

#-----------------------------------------------------------------------------#
#                              On-Ready Variables                             #
#-----------------------------------------------------------------------------#


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#	
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	# Initialize the boss
	initialize(max_health, damage, speed, acceleration, jump_speed, attack_cooldown, dash_cooldown, obeys_gravity, smooth_movement, auto_facing)
	
	# Set the initial animation to play
	_change_animation(_ANIMATION.IDLE)

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# Getters
#=============================


#=============================
# Setters
#=============================

#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#
# Change the animation of the sprite giving a string from the _ANIMATION dictionary.
func _change_animation(animation: Array) -> void:
	# Only perform a change if the animation given isn't already running
	if animation != _current_animation:
		# Make sure the integer given is in the dictionary. If not, give a warning.
		if animation in _ANIMATION.values():
			_current_animation = animation
			
			# First set all the zorro sprites to invisible
			for sprite in $sprites.get_children():
				sprite.visible = false
					
			# Set the correct sprite to visible and play the animation
			$sprites.get_node(_current_animation[1]).visible = true
			$AnimationPlayer.stop()
			$AnimationPlayer.play(_current_animation[0])
			
		else:	
			ProgramAlerts.add_warning("In boss fight AI, attempted to change an animation to non-existant animation id.")

#-----------------------------------------------------------------------------#
#                                Signal Methods                               #
#-----------------------------------------------------------------------------#

#=============================
# Signals that must be setup
#=============================
# Set initial values for use in boss ai here
func _on_zorro_boss_init() -> void:
	set_current_ai_stage(STAGE.ONE)
	set_movement_direction(DIRECTION.LEFT)

# This is only emitted if you are not using entity.gd's auto_facing (which is
# setup in the initialize() method). If you want custom code for flipping your
# ai's entity, disable auto_facing and add custom code here.
func _on_zorro_boss_flip(h_direction_facing) -> void:
	# Flip all dr. geary sprites
	for child in get_node("sprites").get_children():
		if child is Sprite:
			child.scale.x *= -1
				
	# Flip the sword sprite and collision shape
	$sword.scale.x *= -1

# Custom code for when the zorro boss attacks
# Change animations, set movement, etc
func _on_zorro_boss_attack() -> void:
	# Play attack animation
	_change_animation(_ANIMATION.ATTACK)
	
	# Note: the dash() function is called in the AnimationPlayer for the attack animation
	
	# Wait until the attack animation is complete. Pause the ai so
	# physics_process doesn't trigger the current stage ai to run again
	pause_ai()
	print('hi1')
	yield($AnimationPlayer, "animation_finished")
	
	_change_animation(_ANIMATION.IDLE)
	set_movement_enabled(false)
	_timer.start(1.0)
	yield(_timer, "timeout")
	
	# Now that the wait is done, unpause the ai
	print('hi2')
	resume_ai()
	print('hi3')

# Code to run when the ai stage is set to none: likely will be empty function
func _on_zorro_boss_run_no_stage() -> void:
	pass # Replace with function body.

# Code to run when the ai stage is set to one
func _on_zorro_boss_run_stage_one():
	# Enable movement
	set_movement_enabled(true)
	
	# Set the animation for movement
	_change_animation(_ANIMATION.WALK)
	
	# Check to see if boss is within attack range
	if global_position.x - Globals.player_position.x <= standard_distance_from_player and global_position.x - Globals.player_position.x >= 0:
		if get_current_direction().x == DIRECTION.LEFT.x or get_current_direction().x == DIRECTION.NONE.x:
			if abs(global_position.y - Globals.player_position.y) <= Globals.player.get_collision_box_size().y / 2:
				attack()
	elif global_position.x - Globals.player_position.x >= -standard_distance_from_player and global_position.x - Globals.player_position.x <= 0:
		if get_current_direction().x == DIRECTION.RIGHT.x or get_current_direction().x == DIRECTION.NONE.x:
			if abs(global_position.y - Globals.player_position.y) <= Globals.player.get_collision_box_size().y / 2:
				attack()
		
	# If on a wall, switch the state to moving1
	if is_on_wall():
		turn_around()
		jump(1.0)

# Code to run when the ai stage is set to two
func _on_zorro_boss_run_stage_two() -> void:
	pass # Replace with function body.

# Code to run when the ai stage is set to three
func _on_zorro_boss_run_stage_three() -> void:
	pass # Replace with function body.

# Code to run when the ai stage is set to four
func _on_zorro_boss_run_stage_four() -> void:
	pass # Replace with function body.

# Code to run when the ai stage is set to finished
func _on_zorro_boss_fight_ended() -> void:
	pass # Replace with function body.
	

#=============================
# Signals called after an action occurs
#============================= 
# Custom code for dashing (dash already does something but this allows addition
# of more code)
func _on_zorro_boss_dash(multiplier) -> void:
	pass # Replace with function body.	

# Emitted after the ai is paused. Also gives how long it is intended to be
# paused for (this holds true unless unpause_ai() is called)
func _on_zorro_boss_ai_paused(num_seconds) -> void:
	pass # Replace with function body.

# Emitted when the ai is resumed (after a pause)
func _on_zorro_boss_ai_resumed():
	pass # Replace with function body.

# Emitted after an ai_stage is made
func _on_zorro_boss_stage_change(previous_stage, new_stage) -> void:
	pass # Replace with function body.

# Emitted after the ai turns aound either through turn_around() or set_movement_direcion()
func _on_zorro_boss_turn_around() -> void:
	pass


#=============================
# Signals not from ai.gd
#=============================
# Note that player damage is already taken care of using entity.gd
# This signal is meant for puroses other than damage detection
func _on_zorro_boss_collision(body) -> void:
	pass # Replace with function body.
