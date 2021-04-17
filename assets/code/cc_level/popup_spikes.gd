extends Entity

#-----------------------------------------------------------------------------#
#                              Exported Variables                             #
#-----------------------------------------------------------------------------#
# Determines how much damage the damage_box deals
export var damage:           int   = 1
# Determines how much knockback is applied to the player
export var knockback:        float = 10.0
# Determines if the damage_box deals damage
export var deals_damage:     bool  = true
# Determines if the damage_box causes knockback
export var causes_knockback: bool  = true

var can_damage = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var collision = get_node("Area2D")
	
	if $AnimatedSprite.frame > 5 and $AnimatedSprite.frame < 11:
		collision.position.y = 0
		can_damage = true
	if $AnimatedSprite.frame >= 0 and $AnimatedSprite.frame < 5:
		can_damage = false
		collision.position.y = 15

func get_knockback_multiplier() -> float:
	return knockback


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		if deals_damage:
			body.take_damage(damage)
		if causes_knockback: body.knockback  (self, Vector2.UP)
