#-----------------------------------------------------------------------------#
# File Name:   story.gd
# Description: Controls the story node
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 15, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
signal fade_complete
signal on_continue

#-----------------------------------------------------------------------------#
#                             Public Variables                                #
#-----------------------------------------------------------------------------#
var selected_story: String = "roof"

#-----------------------------------------------------------------------------#
#                             Private Variables                               #
#-----------------------------------------------------------------------------#
var _can_continue: bool = false

#-----------------------------------------------------------------------------#
#                              Dictionaries                                   #
#-----------------------------------------------------------------------------#
var _story_text: Dictionary = {
	roof     = "Dr Adkin's Cola has been stolen! Get it back!",
	cc       = "There is water leaking into the building! Avoid the enemies and make it to the stage!",
	ac       = "The building's code looks unstable! Stop the bugs and save the teachers!",
	mk       = "Space has begun to leak into the building! Grab the cola and find a way to stop it!",
	sc       = "What lies in the Sport Center? Might more cola be within, or worse?",
	epilogue = "The cola has been rescued and all is forgiven. Congratulations!"
}

#-----------------------------------------------------------------------------#
#                              Input Events                                   #
#-----------------------------------------------------------------------------#
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("melee_attack") and _can_continue:
		_can_continue = false
		hide()
		emit_signal("on_continue")
	
#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
func fade_in() -> void:
	show()
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("fade_complete")

func fade_out() -> void:
	show()
	$AnimationPlayer.play("fade")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("fade_complete")

func hide() -> void:
	visible = false

func play_story(story_name: String) -> void:
	selected_story = story_name
	show()
	_select_picture(selected_story)
	_select_text(selected_story)
	$AnimationPlayer.play("start_story")
	yield($AnimationPlayer, "animation_finished")

func show() -> void:
	visible = true

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
func _set_continue(can: bool) -> void:
	_can_continue = can

func _select_picture(picture: String) -> void:
	for art in $pictures.get_children():
		art.visible = false
	
	$pictures.get_node(picture).visible = true

func _select_text(text: String) -> void:
	$story_text.text = _story_text[text]
