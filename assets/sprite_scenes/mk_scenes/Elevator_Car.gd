extends Node2D


#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#

const IDLE_DURATION = 2.0
const SPRITE_SIZE   = 32

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#

export var move       = Vector2.RIGHT * (10 * SPRITE_SIZE)
export var move_speed = 5.0

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#

onready var platform = $Platform
onready var tween    = $Tween

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready():
	_init_tween()


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _init_tween():
	var duration = move.length() / float(move_speed * 32)
	tween.interpolate_property(platform, "position", Vector2.ZERO, move,
							   duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
							   IDLE_DURATION)
	tween.interpolate_property(platform, "position", move, Vector2.ZERO,
							   duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT,
							   duration + IDLE_DURATION * 2)
	tween.start()


#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
