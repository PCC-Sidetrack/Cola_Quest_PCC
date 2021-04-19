extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.game_locked = true
	get_tree().paused = true
	$player/game_UI.on_game_ui_visible(false)
	if PlayerVariables.saved_deaths < 1:
		Story.show()
		Story.play("mk")
		yield(Story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	PlayerVariables.new_level()
	
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false
