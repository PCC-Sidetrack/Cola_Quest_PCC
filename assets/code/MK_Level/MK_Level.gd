extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.game_locked = true
	get_tree().paused = true
	$player/game_UI.on_game_ui_visible(false)
	$story.show()
	$story.play("mk")
	yield($story, "on_continue")
	$scene_transition/CanvasLayer/transition.visible = true
	$story.hide()
	$player/game_UI.on_game_ui_visible(true)
	Globals.game_locked = false
	
	$scene_transition/AnimationPlayer.play("transition_out")
	yield($scene_transition/AnimationPlayer, "animation_finished")
	get_tree().paused = false
