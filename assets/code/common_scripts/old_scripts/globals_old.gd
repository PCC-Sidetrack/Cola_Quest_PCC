#-----------------------------------------------------------------------------#
# File Name:   	globals.gd                                                    #
# Description: 	Autoloaded through settings. This class holds global vars     #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 6th, 2020                                            #
#-----------------------------------------------------------------------------#

extends    Node2D
class_name globalsv1

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const GRAVITY:    			float 	= 2000.0
const LAYER_PLAYER:   		int   	= 0
const LAYER_ENEMY:    		int   	= 1
const LAYER_COLLECT:  		int   	= 2
const LAYER_WORLD:  		int   	= 3
const LAYER_INTERACT:		int   	= 4
const LAYER_PROJECTILES:	int 	= 5


#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Holds the current players location (updated by the player script)
var player_position: Vector2 = Vector2(0.0, 0.0)

#-----------------------------------------------------------------------------#
#                               On-Ready Code                                 #
#-----------------------------------------------------------------------------#
# Any code that should be run immediatly as the game starts should be placed here
func _ready() -> void:
	pass
