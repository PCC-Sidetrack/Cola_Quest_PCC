#-----------------------------------------------------------------------------#
# File Name:   running_eagor.gd
# Description: A basic enemy with basic AI
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 6, 2020
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                               Inheiritance                                  #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Speed
export var movement_speed:    float   = 5.0
export var acceleration:      float   = 30.0
export var jump_velocity:     float   = 0.0

export var health:            int     = 1
export var damage:            int     = 1

export var obeys_gravity:     bool    = false
export var sound_timer                = 10.0
export var move_loc:          Vector2

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: Vector2
var player_in_range     = false

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, movement_speed, acceleration, jump_velocity, obeys_gravity)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("Idle")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_loc = Globals.player_position - global_position
	if player_in_range:
		if sound_timer > 2:
			play_attack()
			sound_timer = 0.0
		move_dynamically(move_loc)
		
	sound_timer += _delta

	# Change the direction if the entity hits a wall
#	if is_on_wall():
#		_direction = -_direction
		

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Pisces_collision(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
		
		
func play_attack():
	var t = Timer.new()
	t.set_wait_time(1.5)
	t.set_one_shot(true)
	self.add_child(t)
	$AudioStreamPlayer2D.play()
	t.start()
	yield(t, "timeout")
	$AudioStreamPlayer2D.stop()
	
func _on_Aggro_Range_body_entered(body):
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		player_in_range = true
		print("Player Entered")
		$AnimatedSprite.stop()
		$AnimatedSprite.play("attack")
	
func _on_Aggro_Range_body_exited(body):
	player_in_range = false
	$AnimatedSprite.stop()
	$AnimatedSprite.play("Idle")


func _on_Pisces_health_changed(ammount):
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)


func _on_Pisces_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.disabled = true

	timer.set_one_shot(true)
	add_child(timer)
	
	# Add an audio pitch fade out
	$sword_hit.play()
	$Tween.interpolate_property($AudioStreamPlayer2D, "pitch_scale", $AudioStreamPlayer2D.pitch_scale, 0.01, 50 * 0.04)
	$Tween.start()
	
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()
