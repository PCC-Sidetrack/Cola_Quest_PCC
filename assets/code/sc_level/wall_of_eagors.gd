#-----------------------------------------------------------------------------#
# File Name:   wall_of_eagors.gd
# Description: Prepares the level
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#
extends Node2D

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
const TIME_MIN: float = 0.01
const TIME_MAX: float = 0.05

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
# The sound to be played
export var sound_file: AudioStream

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
var thread

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	thread = Thread.new()
	thread.start(self, "_play_audio", null)

#-----------------------------------------------------------------------------#
#                             Thread Functions                                #
#-----------------------------------------------------------------------------#
# Removes a thread once it has completed
func _exit_tree() -> void:
	thread.wait_to_finish()

#-----------------------------------------------------------------------------#
#                             Private Functions                               #
#-----------------------------------------------------------------------------#
# Play the audio for the wall of eagors
func _play_audio(_userdata) -> void:
	# Create a new audio stream
	var audio = AudioStreamPlayer2D.new()
	
	# Load and configure the audio stream
	audio.stream      = sound_file
	audio.volume_db   = rand_range(-30, -25)
	audio.pitch_scale = rand_range(0.7, 1.3)
	
	# Add audio stream to the scene
	add_child(audio)
	
	# Play the audio stream
	audio.play()
	
	# Yield the audio stream once the audio has finished and remove it from the tree
	yield(get_tree().create_timer(audio.stream.get_length()), "timeout")
	audio.queue_free()

# Start the eagor wall functions
func _start_eagors() -> void:
	$Timer.start(0.1)
	$Particles2D.emitting = true
	$SC_killzone.monitoring    = true
	$SC_killzone.monitorable   = true
	#get_node("Area2D/CollisionShape2D").set_deferred("disable", false)

# Stop the eagor wall functions
func _stop_eagors() -> void:
	$Particles2D.emitting = false
	$SC_killzone.monitoring    = false
	$SC_killzone.monitorable   = false
	#get_node("Area2D/CollisionShape2D").set_deferred("disable", true)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# Once the camera has reached the end of the level
func _on_Camera2D_reached_end() -> void:
	$Timer.paused = true
	$Timer.stop()
	_stop_eagors()

# When the delay timer has finished, play a bird sound
func _on_Timer_timeout() -> void:
	_play_audio(null)
	$Timer.start(rand_range(TIME_MIN, TIME_MAX))


func _on_SC_killzone_body_entered(body: Node) -> void:
	if body == Globals.player and Globals.game_locked == false:
		Globals.player.set_invulnerability(0)
		get_owner().get_node("entities/player/game_UI").on_healing_enabled(false)
		Globals.player.kill()
