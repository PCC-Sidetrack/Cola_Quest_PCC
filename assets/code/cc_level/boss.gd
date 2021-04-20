extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var zacharias_current_position = $paths/balcony_stage/boss_position


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# The code for the change path node
func _change_path(new_path: String) -> void:
	# Get the node for the new path
	var new_parent = $paths.get_node(new_path)
	# Disconnect eagor from its current path
	zacharias_current_position.get_parent().remove_child(zacharias_current_position)
	# Attach eagor to his new path
	new_parent.add_child(zacharias_current_position)

# Stage 1 nodes
func _pick_action1() -> void:
	pass

func _jump() -> void:
	pass

func _punch() -> void:
	pass

func _fire() -> void:
	pass

func _delay1() -> void:
	pass

func _hit1() -> void:
	pass

func _is_dead1() -> void:
	pass

# Stage 2
func _delay2() -> void:
	pass

func _throw() -> void:
	pass

func _hit2() -> void:
	pass

func _is_dead2() -> void:
	pass

# Stage 3
func _pick_action3() -> void:
	pass

func _gust() -> void:
	pass

func _delay() -> void:
	pass

func _swoop() -> void:
	pass

func _hit3() -> void:
	pass

func _is_dead3() -> void:
	pass

func _death() -> void:
	pass
