#-----------------------------------------------------------------------------#
# File Name:   	bird.gd                                                       #
# Description: 	Directs the animation and ai for the bird sprite              #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 12th, 2020                                           #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:         bool  = true
# Movement speed
export var movement_speed:     float = 1.875
# Seconds of movement before changing directions
export var turnaround_time:    float = 3.0
# Start facing right?
export var start_moving_right: bool  = true
export var health:			   int   = 1
export var damage: 			   int   = 1
export var accelertion: 	   float = 20.0


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	
	# Holds the ai instructions
	var instructions: Array
	
	# Set the ai instructions based on which initial direction the bird is moving
	instructions = [
		duration (Vector2.RIGHT if start_moving_right else Vector2.LEFT, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions    (instructions, true)
	initialize_enemy           (health, damage, movement_speed, accelertion)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("fly")


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		move()

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_bird_collision(body):
	pass # Replace with function body.

# Triggered whenever the entity dies	
func _on_bird_death():
	pass # Replace with function body.

# Triggered whenever the entity's health is changed
func _on_bird_health_changed(change):
	pass # Replace with function body.
