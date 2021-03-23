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
		
func spin_sprite():
	var timer: Timer = Timer.new()
	for i in 100:
		timer.set_one_shot(true)
		add_child(timer)
		timer.start(0.01)
		yield(timer, "timeout")
		$AnimatedSprite.rotation_degrees = $AnimatedSprite.rotation_degrees + 30
		i += 1

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
		$AnimatedSprite.stop()
		$AnimatedSprite.play("attack")
	
func _on_Aggro_Range_body_exited(body):
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		player_in_range = false
		$AnimatedSprite.stop()
		$AnimatedSprite.play("Idle")


func _on_Pisces_death():
	var timer: Timer = Timer.new()
	set_collision_mask(0)
	set_collision_layer(0)
	$Dmg_Player.set_collision_mask(0)
	spin_sprite()
	timer.set_one_shot(true)
	add_child(timer)
	
#	play_sound($Hurt, .75)
	
	death_anim (25, 0.01)
	timer.start(25 * 0.04)
	yield(timer, "timeout")
	queue_free()


func _on_Dmg_Player_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
