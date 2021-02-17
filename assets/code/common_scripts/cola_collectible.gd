#-----------------------------------------------------------------------------#
# File Name:   cola_collectible.gd
# Description: A floating cola collectible
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 15, 2020
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_collectable()
	$AnimatedSprite.play("spin")

#-----------------------------------------------------------------------------#
#                                 Triggers                                    #
#-----------------------------------------------------------------------------#
# Because we don't want the player to actually collide with the collectible, we
# need this trigger to deal with the collectible when the player's collision box
# enters it. This is also why the CollisionShape2D outside the Area2D is disabled.
func _on_Area2D_body_entered(body):
	delete()
