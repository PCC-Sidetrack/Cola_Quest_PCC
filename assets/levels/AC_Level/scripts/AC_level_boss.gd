extends Node2D

func _ready():
	$player/game_UI.on_no_checkpoints()
	$player/game_UI.on_player_level_cleared()
	$player/game_UI/cleared/buttons/Control/VBoxContainer/CenterContainer3.visible = false
