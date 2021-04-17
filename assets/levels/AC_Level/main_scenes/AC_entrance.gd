extends Node2D

func _ready():
	Globals.game_locked = true
	$player/game_UI.on_game_ui_visible(false)
	$story.show()
	$story.play("ac")
	yield($story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$story.hide()
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	get_tree().paused = true
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false
	
	$player/game_UI.on_no_checkpoints()

func _on_activate_door_area_entered(area):
	if area.is_in_group("hitbox"):
		SceneFade.change_scene("res://assets/levels/AC_Level/main_scenes/AC_level.tscn", 'fade')
