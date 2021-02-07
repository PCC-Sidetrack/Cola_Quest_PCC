extends Control

# EXTREMELY  WIP 
var flash_amount  = 5   # number of flashes
var flash_counter = 0  
var flash_speed   = 0.1 # lower is faster

func _on_game_UI_flash_screen(color):
	if Globals.game_locked == false and flash_counter < flash_amount:
		$screen_flash.visible = true
		$tween.interpolate_property($screen_flash, "modulate", color , Color.transparent, flash_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$tween.start()
		yield(get_tree().create_timer(flash_speed), "timeout")
		_on_game_UI_flash_screen(color)
		flash_counter += 1
	else: 
		flash_counter = 0
		$screen_flash.visible = false
