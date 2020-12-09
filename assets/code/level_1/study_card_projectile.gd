#-----------------------------------------------------------------------------#
# File Name:   study_card_projectile.gd
# Description: The core of every study card projectile
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        December 1, 2020
#-----------------------------------------------------------------------------#
extends EntityV2

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 2
export var speed:        float = 4.6875
export var acceleration: float = 50.0
export var life_time:    float = 10.0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_projectile(damage, speed, "enemy", global_position.direction_to(Globals.player_position), acceleration, life_time)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(delta: float) -> void:
	move_dynamically(get_current_velocity())
	spin            (Globals.DIRECTION.CLOCKWISE, 10.0)
