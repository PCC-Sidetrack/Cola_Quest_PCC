extends Entity


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var can_damage = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $AnimatedSprite.frame > 5 and $AnimatedSprite.frame < 11:
		can_damage = true
	if $AnimatedSprite.frame >= 0 and $AnimatedSprite.frame < 5:
		can_damage = false


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER) and can_damage:
	#if $AnimatedSprite.frame > 5 and $AnimatedSprite.frame < 11:
		body.knockback(self)
		body.take_damage(1)
