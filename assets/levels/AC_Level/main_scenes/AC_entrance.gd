extends Node2D

func _ready():
	Globals.game_locked = true
	get_tree().paused = true
	$player/game_UI.on_game_ui_visible(false)
	if PlayerVariables.saved_deaths < 1:
		Story.show()
		Story.play("ac")
		yield(Story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	PlayerVariables.new_level()
	
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false
	
	Globals.start_highscore_timer()

func _on_activate_door_area_entered(area):
	if area.is_in_group("hitbox"):
		SceneFade.change_scene("res://assets/levels/AC_Level/main_scenes/AC_level.tscn", 'fade')
		queue_free()
