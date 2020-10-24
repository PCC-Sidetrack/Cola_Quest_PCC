extends Entity

func _ready() -> void:
	set_obeys_gravity(false)
	
func _process(_delta: float) -> void:
	$AnimatedSprite.play("spin")
