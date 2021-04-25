#-----------------------------------------------------------------------------#
# File Name:   story.gd
# Description: Controls the story node
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        April 15, 2021
#-----------------------------------------------------------------------------#
extends CanvasLayer

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
	roof     = "Dr. Adkin's Cola has been taken by Dr. (Geary) Zorro! Get it back!",
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
		if Story.get_node("AnimationPlayer").current_animation_position <= 4.6:
			Story.get_node("AnimationPlayer").seek(4.6, true)
			_can_continue = false
		elif _can_continue:
			_can_continue = false
			hide()
			emit_signal("on_continue")

func _ready() -> void:
	PlayerVariables.reset_values()
	layer = 10
	hide()

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
	$background.visible = false
	$story_text.visible = false
	$continue.visible   = false
	$pictures.visible   = false

func show() -> void:
	$background.visible = true
	$story_text.visible = true
	$continue.visible   = true
	$pictures.visible   = true

# Plays the specified story, but dosn't transition to another scene afterwards
func play(story_name: String) -> void:
	selected_story = story_name
	show()
	_select_picture(selected_story)
	_select_text(selected_story)
	$AnimationPlayer.play("start_story")
	yield($AnimationPlayer, "animation_finished")


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
