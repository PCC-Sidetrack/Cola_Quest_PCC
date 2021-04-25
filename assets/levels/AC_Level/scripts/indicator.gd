extends Node2D

onready var state_machine = $AnimationTree.get("parameters/playback")

func _ready():
	state_machine.travel("bubble_idle")



func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		queue_free()
