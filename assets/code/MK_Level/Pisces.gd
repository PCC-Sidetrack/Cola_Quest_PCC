#-----------------------------------------------------------------------------#
# File Name:   Pisces.gd
# Description: A basic enemy that floats towards the player
# Author:      Luke Hathcock
# Company:     Sidetrack
# Date:        March 15, 2020
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
	for i in 100:
		yield(get_tree().create_timer(0.01), "timeout")
		$AnimatedSprite.rotation_degrees = $AnimatedSprite.rotation_degrees + 30

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Pisces_collision(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
	

func play_attack():
	$AudioStreamPlayer2D.play()
	yield(get_tree().create_timer(1), "timeout")
	$AudioStreamPlayer2D.stop()
	
func _on_Aggro_Range_body_entered(body):
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		player_in_range = true
	
func _on_Aggro_Range_body_exited(body):
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		player_in_range = false


func _on_Pisces_death():
	player_in_range = false
	set_collision_mask(0)
	set_collision_layer(0)
	$Dmg_Player.set_collision_mask(0)
	
	death_anim (25, 0.01)
	yield(spin_sprite(), "completed")
	yield(get_tree().create_timer(25 * 0.04), "timeout")
	queue_free()


func _on_Dmg_Player_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
