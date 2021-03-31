#-----------------------------------------------------------------------------#
# File Name:   door_portal.gd
# Description: Controls the functions of the portal doors
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#

extends Camera2D

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
signal reached_end

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
export var camera_speed:     float   = 2
export var shake_duration:   float = 7
export var shake_frequency:  float = 20
export var shake_amplitude:  float = 8

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Variables for the camera shaking
var _duration         = 0.0
var _period_in_ms     = 0.0
var _amplitude        = 0.0
var _timer            = 0.0
var _last_shook_timer = 0
var _previous_x       = 0.0
var _previous_y       = 0.0
var _last_offset      = Vector2(0, 0)

# Variables for the camera movement
var _is_moving:           bool  = false
var _camera_velocity:     float = 0.0
var _time_between_shakes: float = 15.0
var _time_between_timer:  float = _time_between_shakes

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_process(true)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(delta: float) -> void:
	if _is_moving:
		_camera_velocity = move_toward(0, camera_speed, _camera_velocity + delta)
		position.x += _camera_velocity
		if _time_between_timer >= 0.0:
			_time_between_timer -= delta
		else:
			_time_between_timer = _time_between_shakes
			shake(shake_duration, shake_frequency, shake_amplitude)
	
	if get_camera_screen_center().x >= limit_right - (get_viewport_rect().end.x / 2):
		_is_moving = false
		emit_signal("reached_end")
	

# Shake with decreasing intensity while there's time remaining.
func _process(delta) -> void:
	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
		
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x       = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y       = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x     = new_x
		_previous_y     = new_y
		
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
		
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	# Initialize variables.
	_duration     = duration
	_timer        = duration
	_period_in_ms = 1.0 / frequency
	_amplitude    = amplitude
	_previous_x   = rand_range(-1.0, 1.0)
	_previous_y   = rand_range(-1.0, 1.0)
	
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)
	$AudioStreamPlayer.play()

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Start the chasing sequence
func _start_moving() -> void:
	_is_moving = true

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# The player has reached the node to start the animation sequence
func _on_Area2D_body_entered(body: Node) -> void:
	if body.has_method("prepare_transition"):
		current   = true
		get_node("LeftBorder/CollisionShape2D").set_deferred("disabled", false)
		get_parent().get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
		$AnimationPlayer.play("start_shake")
