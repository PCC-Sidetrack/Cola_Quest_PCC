#-----------------------------------------------------------------------------#
# File Name:   door_portal.gd
# Description: Controls the functions of the portal doors
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        March 23, 2021
#-----------------------------------------------------------------------------#
# Extends a Node2D
extends Node2D

#-----------------------------------------------------------------------------#
#                            Onready Variables                                #
#-----------------------------------------------------------------------------#
onready var state_machine = $AnimationTree.get("parameters/playback")

#-----------------------------------------------------------------------------#
#                                 Signals                                     #
#-----------------------------------------------------------------------------#
# Signal for when the transition has started
signal _on_transition_started
# Signal for when the transition has finished
signal _on_transition_finished

#-----------------------------------------------------------------------------#
#                             Export Variables                                #
#-----------------------------------------------------------------------------#
# Holds the next level to be traveled to
export var next_scene: PackedScene

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Indicates whether the door can be traveled through
var _can_travel: bool = false

#-----------------------------------------------------------------------------#
#                               Input events                                  #
#-----------------------------------------------------------------------------#
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept") or event.is_action_pressed("melee_attack")) and _can_travel:
		if not next_scene:
			return
		else:
			get_tree().paused = true
			$AnimationPlayer.play("transition_in")

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Move the player to the next level
func next_level() -> void:
	Globals.player.prepare_transition()
	var ERR = get_tree().change_scene_to(next_scene)
	
	# Throw and error if no level was given to move to
	if ERR != OK:
		return

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# If the player has entered the doorway, they can travel
func _on_doorway_body_entered(body: Node) -> void:
	if body.has_method("prepare_transition"):
		state_machine.travel("bubble_grow")
		_can_travel = true

# If the player has exited the doorway, they cannot travel
func _on_doorway_body_exited(body: Node) -> void:
	if body.has_method("prepare_transition"):
		state_machine.travel("bubble_shrink")
		_can_travel = false

# Has the animation player finished
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "transition_in":
		emit_signal("_on_transition_started")
		next_level()
	if anim_name == "transition_out":
		emit_signal("_on_transition_finished")
		get_tree().paused = false
