#-----------------------------------------------------------------------------#
# File Name:   spear.gd
# Description: The core for every spear projectile
# Author:      Jeff Newell & Andrew Zedwick
# Company:     Sidetrack
# Date:        December 2, 2020
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 2
export var speed:        float = 9.375
export var acceleration: float = 50.0
export var life_time:    float = 10.0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_projectile      (damage, speed, "enemy", global_position.direction_to(Globals.player_position), acceleration, life_time)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_looking                (true)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(delta: float) -> void:
	move_dynamically(get_current_velocity())

#-----------------------------------------------------------------------------#
#                              Signal Functions                               #
#-----------------------------------------------------------------------------#
func _on_Area2D_body_entered(body):
	delete()
