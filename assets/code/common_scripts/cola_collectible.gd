#-----------------------------------------------------------------------------#
# File Name:   cola_collectible.gd
# Description: A floating cola collectible
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 15, 2020
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Random number generator
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_collectable()
	_rng.randomize()
	$AnimatedSprite.frame = _rng.randi_range(0, $AnimatedSprite.frames.get_frame_count("spin") - 1)
	$AnimatedSprite.play("spin")

#-----------------------------------------------------------------------------#
#                                 Triggers                                    #
#-----------------------------------------------------------------------------#
# Because we don't want the player to actually collide with the collectible, we
# need this trigger to deal with the collectible when the player's collision box
# enters it. This is also why the CollisionShape2D outside the Area2D is disabled.
func _on_Area2D_body_entered(body):
	# Play the collection sound
	_rng.randomize()
	$SD20_coke_collect.pitch_scale = _rng.randf_range(0.9, 1.1)
	$SD20_coke_collect.play()
	
	# Flash the entity
	var t = Timer.new()
	
	t.set_wait_time(0.2)
	t.set_one_shot(true)
	self.add_child(t)
	
	set_modulate(Color(0.3, 1, 0.3, 0.3))
	t.start()
	yield(t, "timeout")
	
	
	set_modulate(Color(1, 1, 1, .5))
	t.start()
	yield(t, "timeout")
	
	# Wait for a moment then delete the entity
	delete()
