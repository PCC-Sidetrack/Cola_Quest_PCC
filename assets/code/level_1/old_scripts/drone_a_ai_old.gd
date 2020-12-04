#-----------------------------------------------------------------------------#
# File Name:   	drone_a_ai.gd                                                 #
# Description: 	Directs the animation and ai for the dronea sprite            #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends EntityOld

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
const STUDY_CARD = preload("res://assets//sprite_scenes//level_1//study_card_projectile.tscn")

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:       bool  = true
# Movement speed
export var movement_speed: 	 float = 6.0
# Projectile speed
export var projectile_speed: float = 150.0
# Projectile lifetime in seconds
export var projectile_life:  float = 10.0
# Seconds before drone shoots a 3x5 card
export var shoot_cooldown:   float = 3.0
# Seconds of movement before changing directions
export var turnaround_time:  int   = 1

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# The vertical direction of current movement
var _vertical_direction: 	float = _UP
# The horizontal direction of the current movement
var _horizontal_direction:	float = _LEFT
# Number of seconds since last movement update
var _movement_update_time:	float = 0.0
# Number of seconds since last 3x5 card was shot
var _shoot_update_time:     float = 0.0


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_obeys_gravity(false)
	set_type("hostile")
	set_speed(0.0, movement_speed)
	_movement_update_time += turnaround_time / 2
	$AnimatedSprite.play("fly")

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_movement_update_time += delta
		_shoot_update_time    += delta
		
		# Handle the movement timer of the drone
		if int(_movement_update_time) >= turnaround_time:
			_vertical_direction = _DOWN if _vertical_direction == _UP else _UP
			_movement_update_time = 0.0
			
		# Handle the shooting timer of the drone
		if int(_shoot_update_time) >= shoot_cooldown: _shoot()
		
		set_velocity((move_and_slide(Vector2(0.0, get_speed().y * _vertical_direction),
				get_floor_normal())))
				
# Create a new instance of a study card projectile and shoot it out of the drone
func _shoot() -> void:
	# Create, initialize, and add a new study card projectile to the drone
	var study_card = STUDY_CARD.instance()
	study_card.initialize(false, projectile_speed, projectile_life)
	study_card.get_node("AnimatedSprite").play("spin")
	$StudyCardSpawn.add_child(study_card)
	_shoot_update_time = 0.0
