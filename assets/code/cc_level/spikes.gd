extends Entity


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export var knockback:        float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func get_knockback_multiplier() -> float:
	return knockback

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self, Vector2.UP)
		body.take_damage(1)
