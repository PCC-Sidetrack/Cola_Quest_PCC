#-----------------------------------------------------------------------------#
# Class Name:   building_selectables
# Description:  Script allowing user to select buildings
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 4/11/2021
#-----------------------------------------------------------------------------#


extends Node2D


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#
# _ready method (called when the node and child nodes this script is connected to
# are initialized and ready to be used)
func _ready() -> void:
	$sports_center/modulation.visible    = false
	$academic_center/modulation.visible  = false
	$makenzie/modulation.visible         = false
	$crown_centre/modulation.visible     = false
	$academic_center2/modulation.visible = false

#-----------------------------------------------------------------------------#
#                                Private Methods                              #
#-----------------------------------------------------------------------------#
# Performs standard animations and actins for loading a level
func _level_transition() -> void:
	get_node("../scene_transition/AnimationPlayer").play("transition_in")
	Globals.stop_highscore_timer()
	Globals.reset_highscore_timer()


#-----------------------------------------------------------------------------#
#                                 Signal Methods                              #
#-----------------------------------------------------------------------------#

func _on_sports_center_mouse_entered():
	Globals.update_local_highscore_from_file()
	$sports_center/modulation/highscore.text = "Highscore: " + str(Globals.get_highscore_dictionary().sports_center as int)
	$sports_center/modulation.visible = true
	
	if get_parent().get_node("day_night_cycle").get_lights_on():
		get_parent().get_node("day_night_cycle/label_glows/label_glow_sc").visible = true


func _on_sports_center_mouse_exited():
	$sports_center/modulation.visible = false
	get_parent().get_node("day_night_cycle/label_glows/label_glow_sc").visible = false


func _on_academic_center_mouse_entered():
	Globals.update_local_highscore_from_file()
	$academic_center/modulation/highscore.text = "Highscore: " + str(Globals.get_highscore_dictionary().academic_center  as int)
	$academic_center/modulation.visible = true
	
	if get_parent().get_node("day_night_cycle").get_lights_on():
		get_parent().get_node("day_night_cycle/label_glows/label_glow_ac").visible = true


func _on_academic_center_mouse_exited():
	$academic_center/modulation.visible = false
	get_parent().get_node("day_night_cycle/label_glows/label_glow_ac").visible = false


func _on_makenzie_mouse_entered():
	Globals.update_local_highscore_from_file()
	$makenzie/modulation/highscore.text = "Highscore: " + str(Globals.get_highscore_dictionary().makenzie  as int)
	$makenzie/modulation.visible = true
	
	if get_parent().get_node("day_night_cycle").get_lights_on():
		get_parent().get_node("day_night_cycle/label_glows/label_glow_mk").visible = true


func _on_makenzie_mouse_exited():
	$makenzie/modulation.visible = false
	get_parent().get_node("day_night_cycle/label_glows/label_glow_mk").visible = false


func _on_crown_centre_mouse_entered():
	Globals.update_local_highscore_from_file()
	$crown_centre/modulation/highscore.text = "Highscore: " + str(Globals.get_highscore_dictionary().crown_centre  as int)
	$crown_centre/modulation.visible = true
	
	if get_parent().get_node("day_night_cycle").get_lights_on():
		get_parent().get_node("day_night_cycle/label_glows/label_glow_cc").visible = true


func _on_crown_centre_mouse_exited():
	$crown_centre/modulation.visible = false
	get_parent().get_node("day_night_cycle/label_glows/label_glow_cc").visible = false


func _on_academic_center2_mouse_entered():
	Globals.update_local_highscore_from_file()
	$academic_center2/modulation/highscore.text = "Highscore: " + str(Globals.get_highscore_dictionary().rooftop  as int)
	$academic_center2/modulation.visible = true
	
	if get_parent().get_node("day_night_cycle").get_lights_on():
		get_parent().get_node("day_night_cycle/label_glows/label_glow_rooftop").visible = true


func _on_academic_center2_mouse_exited():
	$academic_center2/modulation.visible = false
	get_parent().get_node("day_night_cycle/label_glows/label_glow_rooftop").visible = false

func _on_sports_center_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("melee_attack"):
		_level_transition()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://assets/levels/sc_level/SportCenterSection1.tscn")


func _on_academic_center_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("melee_attack"):
		_level_transition()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://assets/levels/AC_Level/main_scenes/AC_entrance.tscn")


func _on_academic_center2_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("melee_attack"):
		_level_transition()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://assets/levels/rooftop_level.tscn")


func _on_makenzie_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("melee_attack"):
		_level_transition()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://assets/levels/MK_Level/MK_Level.tscn")


func _on_crown_centre_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("melee_attack"):
		_level_transition()
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://assets/levels/cc_level/cc_1st_stage.tscn")
