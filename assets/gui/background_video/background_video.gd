extends CanvasLayer

# COMMET NEEDED 
export(int) var speed: int = 20

# COMMET NEEDED 
var direction = Vector2(0,1)

# COMMET NEEDED 
onready var parallax = $ParallaxBackground

# COMMET NEEDED 
func _process(delta):
	parallax.scroll_offset -= Vector2(delta * speed, 0)
	$animations/sprites.play("geary")
