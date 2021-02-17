#-----------------------------------------------------------------------------#
# File Name:    drone_a_ai.gd                                                 #
# Description:  Directs the animation and ai for the dronea sprite            #
# Author:       Jeff Newell & Andrew Zedwick                                  #
# Company:      Sidetrack                                                     #
# Last Updated: December 2, 2020                                              #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
const STUDY_CARD = preload("res://assets//sprite_scenes//level_1//study_card_projectile.tscn")

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:      bool  = true
# Movement speed
export var movement_speed:  float = 0.1875
# Seconds before drone shoots a 3x5 card
export var shoot_cooldown:  float = 3.0
# Seconds of movement before changing directions
export var turnaround_time: float = 1

export var health:       int   = 2
export var damage:       int   = 1
export var acceleration: float = 20.0

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since last movement update
var _movement_update_time: float = 0.0
# Number of seconds since last 3x5 card was shot
var _shoot_update_time:    float = 0.0


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	var instructions = [
		duration (Vector2.UP, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions    (instructions, true)
	initialize_enemy           (health, damage, movement_speed, acceleration)
	
	$AnimatedSprite.play("fly")


#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Overwritten function in Entity.gd that is called whenever a collision occurs
func on_collision(_body: Object):
	pass

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_shoot_update_time += delta
			
		# Handle the shooting timer of the drone
		if int(_shoot_update_time) >= shoot_cooldown:
			_shoot()
		
		move()

# Create a new instance of a study card projectile and shoot it out of the drone
func _shoot() -> void:
	# Save the position of the drone to the misc_loc vector in Globals. It will
	# be used by the study card.
	Globals.misc_loc = global_position
	
	# Create, initialize, and add a new study card projectile to the drone
	var study_card = STUDY_CARD.instance()
	#study_card.get_node("AnimatedSprite").play("spin")
	$StudyCardSpawn.add_child(study_card)
	_shoot_update_time = 0.0
		
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_drone_a_collision(_body):
	pass # Replace with function body.

func _on_drone_a_death():
	pass # Replace with function body.

func _on_drone_a_health_changed(_change):
	pass # Replace with function body.
