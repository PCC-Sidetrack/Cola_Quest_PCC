extends Node2D


func _on_activate_door_area_entered(area):
	if area.is_in_group("hitbox"):
		SceneFade.change_scene("res://assets/levels/AC_Level/main_scenes/AC_level.tscn", 'fade')
