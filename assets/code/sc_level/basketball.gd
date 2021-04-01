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
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	pass

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	rotate(0.1)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
func get_speed() -> int:
	return speed

func get_knockback_multiplier() -> int:
	return knockback

func ball_force(direction, impulse) -> void:
	apply_impulse(direction, impulse)

func start_lifetime() -> void:
	$Timer.start(life_time)

func take_damage(_damage: int) -> void:
	queue_free()
#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# Has the basketball hit something
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("wall"):
		queue_free()
	elif area.is_in_group("player"):
		queue_free()

func _on_Timer_timeout() -> void:
	queue_free()

func _on_basketball_body_entered(body: Node) -> void:
	$AudioStreamPlayer2D.play()
