extends Entity

func _ready() -> void:
	set_obeys_gravity(false)
	set_type         ("collectible")
	$AnimatedSprite.play("spin")
