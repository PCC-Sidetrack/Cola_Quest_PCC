#-----------------------------------------------------------------------------#
# File Name:   cola_collectible.gd
# Description: A floating cola collectible
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 15, 2020
#-----------------------------------------------------------------------------#

extends EntityV2

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_collectable()
	$AnimatedSprite.play("spin")
