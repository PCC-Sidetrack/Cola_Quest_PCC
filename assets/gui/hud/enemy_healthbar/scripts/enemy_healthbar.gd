extends TextureProgress

func _visible_timeout():
	self.visible = false

func _on_jellyfish_just_damaged():
	self.visible = true
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")
