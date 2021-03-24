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
# Selector for play    button 
onready var selector_one   = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/selector
# Selector for credits button 
onready var selector_two   = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer/selector
# Selector for exit    button 
onready var selector_three = $main_menu_options/CenterContainer/VBoxContainer/CenterContainer4/HBoxContainer/selector
# Selector currently being selected 
var current_selection:int  = 0
# Menu start  
var menu_start:int         = 0
# Menu credits 
var menu_credits:int       = 1
# Menu exit 
var menu_exit:int          = 2 
# Menu opened
var menu_opened:bool       = false

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Main menu initialization
func _ready()  -> void:
	_set_current_selection(menu_start)
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
				$sounds/play_button.play()
				yield(get_tree().create_timer(0.3), "timeout")
				SceneFade.change_scene("res://assets/levels/rooftop_level.tscn", 'fade')
				queue_free()
			menu_credits:
				menu_opened                      = true
				$credits/CenterContainer.visible = true
				$main_menu_options/CenterContainer/AnimationPlayer.play('menu_fade_away')

			menu_exit:
				get_tree().quit()

# Set current selection 
func _set_current_selection(_current_selection) -> void:
	selector_one.visible   = false
	selector_two.visible   = false
	selector_three.visible = false
	if _current_selection == menu_start:
		selector_one.visible = true
	elif _current_selection == menu_credits:
		selector_two.visible = true
	elif _current_selection == menu_exit:
		selector_three.visible = true

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
		$sounds/credits_button.play()

# On clicking menu exit
func _on_exit_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		$sounds/exit_button.play()
		yield(get_tree().create_timer(0.5), "timeout")
		_handle_selection(current_selection)

# On clicking back button
func _on_back_button_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		menu_opened                       = false
		$credits/CenterContainer.visible  = false
		$main_menu_options/CenterContainer/AnimationPlayer.play_backwards("menu_fade_away")

