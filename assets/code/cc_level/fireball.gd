#-----------------------------------------------------------------------------#
# File Name:   fireball.gd
# Description: The fireball for the zacharias boss fight
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 21, 2021
#-----------------------------------------------------------------------------#
extends RigidBody2D

export var damage: int = 1

func fire_force(direction, impulse) -> void:
	apply_impulse(direction, impulse)
	$Sprite.flip_h = sign(impulse.x) < 0

func take_damage(_damage: int) -> void:
	pass

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		if $Sprite.flip_h:
			body.set_velocity(Vector2(-1000, 0))
		else:
			body.set_velocity(Vector2(1000, 0))
		queue_free()


func _on_hitbox_body_exited(body: Node) -> void:
	if body.is_in_group("world"):
		queue_free()
