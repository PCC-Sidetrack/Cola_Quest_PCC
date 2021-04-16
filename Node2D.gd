extends Node2D

func _ready() -> void:
	Story.fade_in()
	yield(Story, "fade_complete")
	Story.play_story("cc")
