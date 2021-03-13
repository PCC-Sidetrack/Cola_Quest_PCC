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
export var movement_speed:  float = 1.5
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
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
func set_initial_direction_moving(direction: Vector2 = Vector2.DOWN) -> void:
	var instructions = [
		duration (direction, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions (instructions, true)
		
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_drone_b_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.disabled = true
	timer.set_one_shot(true)
	add_child(timer)
	
	# Add an audio fade out
	$sword_hit.play()
	$Tween.interpolate_property($AudioStreamPlayer2D, "pitch_scale", $AudioStreamPlayer2D.pitch_scale, 0.01, 50 * 0.04)
	$Tween.start()
	
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()

func _on_drone_b_health_changed(ammount):
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
