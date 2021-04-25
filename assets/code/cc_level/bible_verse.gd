#-----------------------------------------------------------------------------#
# File Name:    bible_verse.gd                                                #
# Description:  #
# Author:       Sephrael Lumbres                                              #
# Company:      Sidetrack                                                     #
# Last Updated: April 10, 2021                                                #
#-----------------------------------------------------------------------------#
extends Node2D

signal transition_complete

onready var camera = get_node("../player/Camera2D")
#const TRANSITION_IN_OFFSET  = 0
#const TRANSITION_OUT_OFFSET = 100
const TRANSITION_SPEED      = 2.0
#var   transition_offset     = TRANSITION_OUT_OFFSET
#var   lerp_value            = 1.0
var   transition_in         = true

func _ready() -> void:
	$AnimationPlayer.playback_speed = TRANSITION_SPEED

#func _process(delta: float) -> void:
#	lerp_value += TRANSITION_SPEED * delta 
#
#	if lerp_value > 1.0:
#		lerp_value = 1.0
#
#	if not transition_in:
#		transition_offset = lerp(TRANSITION_IN_OFFSET, TRANSITION_OUT_OFFSET, lerp_value)
#		$textbox.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
#		$Reference.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
#		$Verse.set_modulate(Color(1.0, 1.0, 1.0, 1.0 - lerp_value))
#	else:
#		transition_offset = lerp(TRANSITION_OUT_OFFSET, TRANSITION_IN_OFFSET, lerp_value)
#		$textbox.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))
#		$Reference.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))
#		$Verse.set_modulate(Color(1.0, 1.0, 1.0, lerp_value))
#	
#	
#	if Input.is_action_pressed("ui_accept"):
#		transition_in_out(false)

func finished() -> void:
	emit_signal("transition_complete")
