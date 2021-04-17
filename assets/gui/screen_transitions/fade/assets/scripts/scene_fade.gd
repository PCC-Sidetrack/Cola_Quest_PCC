#-----------------------------------------------------------------------------#
# Class Name:   scene_fade.gd
# Description:  Fades the screen into another scene
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: March 27, 2021
#-----------------------------------------------------------------------------#
extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Animation player node
onready var Anim = $Control/AnimationPlayer

# Scene to be transitioned into 
var scene : String

#-----------------------------------------------------------------------------#
#                                Functions                                    #
#-----------------------------------------------------------------------------#
# Animate transition into new scene  
func change_scene(new_scene, animation):
	scene = new_scene
	Anim.play(animation)

# Change current scene into new scene
func _new_scene():
	return get_tree().change_scene(scene)

# Lock the game 
func _game_lock():
	Globals.game_locked = true

# Unlock the game 
func _game_unlock():
	Globals.game_locked = false
