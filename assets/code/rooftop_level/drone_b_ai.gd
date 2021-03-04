#-----------------------------------------------------------------------------#
# File Name:    drone_b_ai.gd                                                 #
# Description:  Directs the animation and ai for the dronea sprite            #
# Author:       Jeff Newell & Andrew Zedwick                                  #
# Company:      Sidetrack                                                     #
# Last Updated: December 2, 2020                                              #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:      bool  = true
# Movement speed
export var movement_speed:  float = 1.5625
# Seconds of movement before changing directions
export var turnaround_time: float = 2
# Acceleration applied to drone's movement
export var acceleration:    float = 20.0
# Knockback multiplier for drone
export var knockback:       float = 0.8

# Stores how much health the drone has
export var health:       int   = 2
# Amount of damage the drone deals
export var damage:       int   = 1
#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	var instructions: Array = [
		duration (Vector2.UP, turnaround_time),
		end_point(global_position)
	]
	initialize_instructions (instructions, true)
	initialize_enemy        (health, damage, movement_speed, acceleration)
	set_knockback_multiplier(knockback)
	
	$AnimatedSprite.play("fly")
	$AudioStreamPlayer2D.play()


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(_delta: float) -> void:
	if ai_enabled:
		move()
		
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_drone_b_collision(body):
	if body.is_in_group(Globals.GROUP.PLAYER) && body is Entity:
		body.deal_damage(self)
		body.knockback(self)

func _on_drone_b_death():
	pass # Replace with function body.

func _on_drone_b_health_changed(_change):
	pass # Replace with function body.