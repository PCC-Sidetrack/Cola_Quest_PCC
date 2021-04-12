#-----------------------------------------------------------------------------#
# Class Name:   mouse_move_camera
# Description:  Moves camera based on mouse position
# Author:       Andrew Zedwick
# Company:      Sidetrack
# Last Updated: 3/30/2021
#-----------------------------------------------------------------------------#

extends Camera2D

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Used to set the initial zoom of the camera
var _initial_zoom:    Vector2 = Vector2(3.0, 3.0)
# Multiplier affecting how much zoom in and out is applied when zooming
var _zoom_multiplier: float = 1.0
# Time in seconds for one zoom calculation to occur
var _zoom_speed:      float = 0.1
var _min_zoom:        float = 0.8
var _max_zoom:        float = 6.0

#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#

func _ready():
	zoom = _initial_zoom

func _process(delta) -> void:
	position = get_global_mouse_position()
	
	# Check if currently zooming in our out by using plus or minus key
	if Input.is_action_pressed("zoom_in"):
		if zoom.x > _min_zoom and zoom.y > _min_zoom:
			zoom.x -= delta * 2 * _zoom_multiplier
			zoom.y -= delta * 2 * _zoom_multiplier
	elif Input.is_action_pressed("zoom_out"):
		if zoom.x < _max_zoom and zoom.y < _max_zoom:
			zoom.x += delta * 2 * _zoom_multiplier
			zoom.y += delta * 2 * _zoom_multiplier
	
# Check for mouse scroll zoom
func _unhandled_input(event):	
	# Check if currently zooming in our out
	if event.is_action_pressed("wheel_zoom_in"):
		# Temporary zoom vector
		var new_zoom: Vector2 = Vector2(zoom.x - (0.5 * _zoom_multiplier), zoom.y - (0.5 * _zoom_multiplier))
		
		if zoom.x > _min_zoom and zoom.y > _min_zoom:
			$Tween.interpolate_property(self, "zoom", zoom, new_zoom, _zoom_speed)
			$Tween.start()
	elif event.is_action_pressed("wheel_zoom_out"):
		# Temporary zoom vector
		var new_zoom: Vector2 = Vector2(zoom.x + (0.5 * _zoom_multiplier), zoom.y + (0.5 * _zoom_multiplier))
		
		if zoom.x < _max_zoom and zoom.y < _max_zoom:
			$Tween.interpolate_property(self, "zoom", zoom, new_zoom, _zoom_speed)
			$Tween.start()
	
