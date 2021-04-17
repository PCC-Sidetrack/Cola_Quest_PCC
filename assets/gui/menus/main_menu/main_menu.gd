#-----------------------------------------------------------------------------#
# Class Name:   main_menu.gd
# Description:  Controls the main menu components
# Author:       Rightin Yamada
# Company:      Sidetrack
# Last Updated: March 23, 2021
#-----------------------------------------------------------------------------#

extends CanvasLayer

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Selector for play       button 
onready var selector_one        = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/selector
# Selector for credits    button 
onready var selector_two        = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer/selector
# Selector for exit       button 
onready var selector_three      = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer4/HBoxContainer/selector
# Selector for play intro button
onready var selector_play_intro = $skip_intro_level/Control/VBoxContainer/CenterContainer/HBoxContainer/selector
# Selector for skip intro buton
onready var selector_skip_intro = $skip_intro_level/Control/VBoxContainer/CenterContainer2/HBoxContainer/selector

# Selector currently being selected 
var current_selection:int  = 0
# Menu start  
var menu_start:       int  = 0
# Menu credits 
var menu_credits:     int  = 1
# Menu exit 
var menu_exit:        int  = 2 
# Play intro
var play_intro:       int  = 3
# Skip intro
var skip_intro:       int  = 4
# Menu opened
var menu_opened:      bool = false


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Main menu initialization
func _ready()  -> void:
	_set_current_selection(menu_start)
	$skip_intro_level/Control.visible          = false
	$main_menu_options/CenterContainer.visible = true
	$credits/CenterContainer.visible           = false
	
# Select menu option 
func _input(event) -> void:
	if Globals.game_locked == false and menu_opened == false:
		if event.is_action_pressed("ui_up") and current_selection > menu_start:
			current_selection -= 1 
			_set_current_selection(current_selection)
			$sounds/mouse_button_hover.play()
		elif event.is_action_pressed("ui_down") and current_selection < menu_exit:
			current_selection += 1 
			_set_current_selection(current_selection)
			$sounds/mouse_button_hover.play()
		elif event.is_action_pressed("ui_up") and current_selection == menu_start:
			current_selection = menu_exit
			_set_current_selection(current_selection)
			$sounds/mouse_button_hover.play()
		elif event.is_action_pressed("ui_down") and current_selection == menu_exit:
			current_selection = menu_start
			_set_current_selection(current_selection)
			$sounds/mouse_button_hover.play()
		elif event.is_action_pressed("ui_accept"):
			_handle_selection(current_selection)

# Handle current selection 
func _handle_selection(_current_selection) -> void:
	if Globals.game_locked == false:
		match _current_selection:
			menu_start:
				menu_opened = true
				$skip_intro_level/Control.visible = true
				$main_menu_options/CenterContainer/AnimationPlayer.play('menu_fade_away')
#				$sounds/play_button.play()
#				Globals.game_locked = true
#				SceneFade.change_scene("res://assets/levels/rooftop_level.tscn", 'fade')
#				yield($sounds/play_button, "finished")
#				queue_free()
			menu_credits:
				$sounds/credits_button.play()
				menu_opened                      = true
				$credits/CenterContainer.visible = true
				$main_menu_options/CenterContainer/AnimationPlayer.play('menu_fade_away')
			menu_exit:
				$sounds/exit_button.play()
				Globals.game_locked = true
				$main_menu_options/CenterContainer/AnimationPlayer.play('menu_fade_away')
				yield($sounds/exit_button, "finished")
				get_tree().quit()
			play_intro:
				$sounds/play_button.play()
				Globals.game_locked = true
				SceneFade.change_scene("res://assets/levels/rooftop_level.tscn", 'fade')
				yield($sounds/play_button, "finished")
				queue_free()
			skip_intro:
				$sounds/play_button.play()
				Globals.game_locked = true
				SceneFade.change_scene("res://assets/levels/hub.tscn", 'fade')
				yield($sounds/play_button, "finished")
				queue_free()

# Set current selection 
func _set_current_selection(_current_selection) -> void:
	selector_one.visible        = false
	selector_two.visible        = false
	selector_three.visible      = false
	selector_play_intro.visible = false
	selector_skip_intro.visible = false
#	if _current_selection == menu_start:
#		selector_one.visible = true
#	elif _current_selection == menu_credits:
#		selector_two.visible = true
#	elif _current_selection == menu_exit:
#		selector_three.visible = true
	
	match _current_selection:
		menu_start:
			selector_one.visible        = true
		menu_credits:
			selector_two.visible        = true
		menu_exit:
			selector_three.visible      = true
		play_intro:
			selector_play_intro.visible = true
		skip_intro:
			selector_skip_intro.visible = true

#-----------------------------------------------------------------------------#
#                             Trigger Functions                               #
#-----------------------------------------------------------------------------#
# On mouse detected on menu start
func _on_start_mouse_entered() -> void:
	current_selection = menu_start
	_set_current_selection(menu_start)
	$sounds/mouse_button_hover.play()

# On mouse detected on menu credits
func _on_credits_mouse_entered() -> void:
	current_selection = menu_credits
	_set_current_selection(menu_credits)
	$sounds/mouse_button_hover.play()

# On mouse detected on menu exit
func _on_exit_mouse_entered() -> void:
	current_selection = menu_exit
	_set_current_selection(menu_exit)
	$sounds/mouse_button_hover.play()

# On clicking on menu start
func _on_start_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)

# On clicking on menu credits
func _on_credits_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)

# On clicking menu exit
func _on_exit_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)

# On clicking back button
func _on_back_button_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		menu_opened                       = false
		$credits/CenterContainer.visible  = false
		$skip_intro_level/Control.visible = false
		$main_menu_options/CenterContainer/AnimationPlayer.play_backwards("menu_fade_away")

func _on_play_intro_gui_input(event):
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)

func _on_play_intro_mouse_entered():
	current_selection = play_intro
	_set_current_selection(play_intro)
	$sounds/mouse_button_hover.play()

func _on_skip_intro_mouse_entered():
	current_selection = skip_intro
	_set_current_selection(skip_intro)
	$sounds/mouse_button_hover.play()

func _on_skip_intro_gui_input(event):
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)
