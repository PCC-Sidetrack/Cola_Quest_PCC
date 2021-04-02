#-----------------------------------------------------------------------------#
# Class Name:   background_video.gd
# Description:  Main menu background
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: March 24, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Speed of background 
export(int) var speed: int = 20

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Pan the background left every delta process 
func _process(delta) -> void:
	$ParallaxBackground.scroll_offset -= Vector2(delta * speed, 0)
	$animations/sprites.play("geary")
