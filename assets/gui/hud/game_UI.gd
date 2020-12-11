extends Control

signal player_killed
signal level_cleared
signal health_changed(current_health, previous_health)
signal low_health

func _on_Player_killed():
	emit_signal("player_killed")

func _on_Player_level_cleared():
	emit_signal("level_cleared")

func _on_Health_health_changed(current_health, previous_health):
	emit_signal("health_changed", current_health, previous_health)

func _on_Health_low_health():
	emit_signal("low_health")
