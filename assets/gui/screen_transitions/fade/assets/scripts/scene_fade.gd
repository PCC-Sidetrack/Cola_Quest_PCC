extends CanvasLayer

# COMMET NEEDED 
onready var Anim = $Control/AnimationPlayer
# COMMET NEEDED 
var scene : String

# COMMET NEEDED 
func change_scene(new_scene, animation):
	scene = new_scene
	Anim.play(animation)

# COMMET NEEDED 
func _new_scene():
	return get_tree().change_scene(scene)

# COMMET NEEDED 
func _game_lock():
	Globals.game_locked = true

# COMMET NEEDED 
func _game_unlock():
	Globals.game_locked = false
