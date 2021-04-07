#-----------------------------------------------------------------------------#
# File Name:   basketball.gd
# Description: The functions for the basketball projectile
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 25, 2021
#-----------------------------------------------------------------------------#

# Extends RigidBody2D
extends RigidBody2D

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var damage:    int = 1
export var knockback: int = 1.0
export var life_time: int = 3
export var speed:     int = 16

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	rotate(0.1)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# This function is only here because of how melee combat was implemented
# In this entity, it is completely useless
func custom_knockback(_useless_parameter1, _useless_parameter2) -> void:
	pass

# Get the speed of the basketball
func get_speed() -> int:
	return speed

# Get the knockback multiplier of the basketball
func get_knockback_multiplier() -> int:
	return knockback

# Apply a force to the basketball
func ball_force(direction, impulse) -> void:
	apply_impulse(direction, impulse)

# Start the basketball's lifetime
func start_lifetime() -> void:
	$Timer.start(life_time)

# Delete the basketball if it takes damage
func take_damage(_damage: int) -> void:
	queue_free()
#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# This detects the the players hurtbox and causes damage
# Saved in case we switch to the conventional hitbox/hurtbox system
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Globals.GROUP.PLAYER) and area.is_in_group("hurtbox"):
		area.get_parent().take_damage(damage)
		queue_free()

# This detects the the player and causes damage
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		queue_free()

# When the lifetime timer runs out, delete the basketball
func _on_Timer_timeout() -> void:
	queue_free()

# If the basketball hits something, make it play the bounce sound
func _on_basketball_body_entered(_body: Node) -> void:
	$AudioStreamPlayer2D.play()