extends AnimatedSprite

func _ready():
	self.play()
	$bomb_explosion.play()
	yield(self, "animation_finished")
	queue_free()
