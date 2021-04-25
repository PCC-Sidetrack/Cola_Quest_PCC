extends Entity


var max_health = 50
var invlunerability_time: float   = 0.7

# Called when the node enters the scene tree for the first time.
func _ready():
	get_owner().get_node("player/game_UI").on_initialize_boss(max_health, "fred")
	print(max_health)
	set_max_health(max_health)
	set_current_health(get_max_health())
	print(get_current_health())
	$GREEN_05.visible = true
	$WT_01.visible = false


func _on_Area2D_area_entered(_area):
	get_owner().get_node("player/game_UI").on_boss_healthbar_visible(true)
	get_owner().get_node("player/game_UI").on_cola_collect(1)
	_on_boss_health_changed(20)

func _on_boss_health_changed(change) -> void:
	get_owner().get_node("player/game_UI").on_flash_screen(Color.blue)
	get_owner().get_node("player/game_UI").on_boss_health_changed(get_current_health(), get_current_health() - change)
	take_damage(change)
	print(get_current_health())
	if(get_current_health() <= 0 ):	
		$GREEN_05.visible = false
		$WT_01.visible    = true 
		Globals.game_locked = true
		get_owner().get_node("player/game_UI").on_boss_healthbar_visible(false)
		get_owner().get_node("player/game_UI").on_player_level_cleared(0)
