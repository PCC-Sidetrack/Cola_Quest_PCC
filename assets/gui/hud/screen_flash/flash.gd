#-----------------------------------------------------------------------------#
# Class Name:   flash.gd                                          
# Description:  Flash the screen for a given duration and color
# Author:       Rightin Yamada                
# Company:      Sidetrack
# Last Updated: February 10, 2021
#-----------------------------------------------------------------------------#
# NOTICE: THIS CODE IS VERY BLAH, WILL WORK ON EVENTUALLY, PROBABLY, 

extends Control

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Amount of flashes
var flash_amount:  int   = 5  
# Flash counter 
var flash_counter: int   = 1   
# Speed of the flashes
var flash_speed:   float = 0.1 

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# On being called, flash the screen given a color
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
