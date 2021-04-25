#-----------------------------------------------------------------------------#
# Class Name:   day_night_cycle.gd
# Description:  Controls the lights for the hub level
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 4/25/2021
#-----------------------------------------------------------------------------#

extends Node


#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Used to determine if the lights are currently on
var _lights_on:     bool  = false
# Random number generator
var _rng:           RandomNumberGenerator
# Light blink refresh number
var _blink_refresh: float = 0.0


#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	# Make sure no lights are visible
	for node in $lights.get_children():
		for light in node.get_children():
			light.visible = false
			
	for label_glow in $label_glows.get_children():
		label_glow.visible = false
			
func _physics_process(delta) -> void:
	# Update the blink_refresh number
	_blink_refresh += delta
	
	# Perform light blinking if the lights are on and the refresh is done
	if _lights_on and _blink_refresh >= _rng.randf_range(0.3, 2):
		_blink_refresh = 0.0
		
		# Loop processing all day-night-cycle lights
		for container in $lights.get_children():
			for light in container.get_children():
				# 1 in 30 chance of a blink occurring
				if not _rng.randi_range(0, 29):
					light.visible = false
					yield(get_tree().create_timer(_rng.randf_range(0.05, 0.4)), "timeout")
					light.visible = true

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
# Turns the lights on
func turn_on_lights() -> void:
	# Turn on the lights with a time interval gap
	for container in $lights.get_children():
		for light in container.get_children():
			yield(get_tree().create_timer(_rng.randf_range(0.05, 0.3)), "timeout")
			light.visible = true
			
	_lights_on = true
	
# Turns the lights off
func turn_off_lights() -> void:
	_lights_on = false
	
	# Turn off the lights with a time interval gap
	for container in $lights.get_children():
		for light in container.get_children():
			yield(get_tree().create_timer(_rng.randf_range(0.05, 0.3)), "timeout")
			light.visible = false
			
func get_lights_on() -> bool:
	return _lights_on
