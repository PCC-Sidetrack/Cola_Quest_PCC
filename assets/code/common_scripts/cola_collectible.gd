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
	set_obeys_gravity   (false)
	set_type            ("collectible")
	$AnimatedSprite.play("spin")
