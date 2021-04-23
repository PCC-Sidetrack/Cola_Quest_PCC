extends Area2D

onready var boss_movement = get_parent().get_parent().get_node("enemies/boss/movement/movement_machine").get("parameters/playback")

func _on_Area2D2_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		boss_movement.start("p_balcony")
		boss_movement.travel("p_stage_right")
		
		queue_free()
