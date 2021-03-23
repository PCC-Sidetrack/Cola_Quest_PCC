extends CanvasLayer

# COMMET NEEDED 
const credits_scene = preload("res://assets/gui/menus/main_menu/credits.tscn")

# COMMET NEEDED 
onready var selector_one   = $CenterContainer/VBoxContainer/CenterContainer2/HBoxContainer/selector
# COMMET NEEDED 
onready var selector_two   = $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer/selector
# COMMET NEEDED 
onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer4/HBoxContainer/selector

# COMMET NEEDED 
var current_selection      = 0
# COMMET NEEDED 
var menu_start             = 0
# COMMET NEEDED 
var menu_credits           = 1
# COMMET NEEDED 
var menu_exit              = 2 

# COMMET NEEDED 
func _ready() -> void:
	_set_current_selection(menu_start)

# COMMET NEEDED 
func _input(event) -> void:
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

# COMMET NEEDED 
func _handle_selection(_current_selection) -> void:
	match _current_selection:
		menu_start:
			$sounds/play_button
			SceneFade.change_scene("res://assets/levels/rooftop_level.tscn", 'fade')
			queue_free()
		menu_credits:
			get_parent().add_child(credits_scene.instance())
			queue_free()
		menu_exit:
			get_tree().quit()

# COMMET NEEDED 
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

# COMMENT NEEDED
func _on_start_mouse_entered() -> void:
	current_selection = menu_start
	_set_current_selection(menu_start)
	$sounds/mouse_button_hover.play()

# COMMENT NEEDED
func _on_credits_mouse_entered() -> void:
	current_selection = menu_credits
	_set_current_selection(menu_credits)
	$sounds/mouse_button_hover.play()

# COMMENT NEEDED
func _on_exit_mouse_entered() -> void:
	current_selection = menu_exit
	_set_current_selection(menu_exit)
	$sounds/mouse_button_hover.play()

# COMMENT NEEDED
func _on_start_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)


# COMMENT NEEDED
func _on_credits_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)
		$sounds/credits_button

# COMMENT NEEDED
func _on_exit_gui_input(event) -> void:
	if event.is_action_pressed("melee_attack"):
		_handle_selection(current_selection)
		$sounds/exit_button
