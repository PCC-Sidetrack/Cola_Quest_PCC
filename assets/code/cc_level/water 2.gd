tool

#-----------------------------------------------------------------------------#
# File Name:    water.gd                                                      #
# Description:  Sets the water shader scale as the same as the sprite scale   #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: March 25, 2021                                                #
#-----------------------------------------------------------------------------#

extends Sprite

func _process(_delta: float) -> void:
	material.set_shader_param("sprite_scale", scale);

func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void:
	Globals.game_locked = false
