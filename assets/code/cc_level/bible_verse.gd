#-----------------------------------------------------------------------------#
# File Name:    bible_verse.gd                                                #
# Description:  #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: April 10, 2021                                                #
#-----------------------------------------------------------------------------#
extends Node2D

onready var camera = get_node("../player/Camera2D")
const TRANSITION_IN_OFFSET  = 0
const TRANSITION_OUT_OFFSET = 1000
const TRANSITION_SPEED      = 1.0
var   transition_offset     = TRANSITION_OUT_OFFSET
var   lerp_value            = 1.0
var   transition_in         = false

func _process(delta: float) -> void:
	lerp_value += TRANSITION_SPEED * delta
	
	if lerp_value > 1.0:
		lerp_value = 1.0

	if not transition_in:
		transition_offset = lerp(TRANSITION_IN_OFFSET, TRANSITION_OUT_OFFSET, lerp_value)
		$textbox.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
		$Reference.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
		$Verse.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
	else:
		transition_offset = lerp(TRANSITION_OUT_OFFSET, TRANSITION_IN_OFFSET, lerp_value)
		$textbox.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))
		$Reference.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))
		$Verse.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))

	position = camera.get_camera_position() + Vector2(0, transition_offset)

#	if Input.is_action_pressed("ui_accept"):
#		transition_in_out(false)

func transition_in_out(var trans_in):
	if(trans_in != transition_in):
		lerp_value = 0.0
		transition_in = trans_in
