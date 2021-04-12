extends RigidBody2D

var explosion = preload("res://assets/levels/AC_Level/assets/sprites/bullet_explosion.tscn")
var damage    = 1

func _ready():
	$lifetime.start()
	

func _on_Bullet_body_entered(body):
	var explosion_instance = explosion.instance()
	explosion_instance.position = get_global_position()
	get_tree().get_root().add_child(explosion_instance)
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	queue_free()



func _on_lifetime_timeout():
	queue_free()
