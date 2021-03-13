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
export var health:			   int   = 5
export var damage: 			   int   = 1
export var accelertion: 	   float = 20.0
export var knockback:          float = 0.8


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
	set_knockback_multiplier   (knockback)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_auto_facing            (true)
	
	
	$AnimationPlayer.play("fly")
	$AudioStreamPlayer2D.play()
	$healthbar.max_value = health


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
# Triggered whenever the entity dies	
func _on_bird_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.disabled = true
	timer.set_one_shot(true)
	add_child(timer)
	
	# Add an audio fade out
	$Tween.interpolate_property($AudioStreamPlayer2D, "pitch_scale", $AudioStreamPlayer2D.pitch_scale, 0.01, 50 * 0.04)
	$Tween.start()
	
	$sword_hit.play()
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()


func _on_bird_health_changed(ammount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 
