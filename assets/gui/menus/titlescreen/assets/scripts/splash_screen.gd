#-----------------------------------------------------------------------------#
# Class Name:   splash_screen.gd
# Description:  Splash Screen
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: March 6, 2021
#-----------------------------------------------------------------------------#
extends TextureRect

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Fade away the loading can 
func _ready():
	yield(get_tree().create_timer(.4), "timeout")
	$AnimationPlayer.play("can_fade_away")
	$coke_fade_away.play()

# When an animation finishes
func _on_AnimationPlayer_animation_finished(anim_name):
	# On fade away can, move logo onto screen
	if anim_name == "can_fade_away":
		$AnimationPlayer.play("logo_fade_into")
		$logo_fade_into.play()
	
	# On logo on screen, change scene
	if anim_name == "logo_fade_into":
		return get_tree().change_scene("res://assets/levels/rooftop_level.tscn")
