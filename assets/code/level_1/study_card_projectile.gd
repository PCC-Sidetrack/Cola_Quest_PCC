#-----------------------------------------------------------------------------#
# File Name:   study_card_projectile.gd
# Description: The core of every study card projectile
# Author:      Jeff Newell & Andrew Zedwick
# Company:     Sidetrack
# Date:        December 1, 2020
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 2
export var speed:        float = 4.6875
export var acceleration: float = 50.0
export var life_time:    float = 10.0

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Overwritten function in Entity.gd that is called whenever a collision occurs
func on_collision(body: Object):
	# Check what body was collided with
	if body.has_method("is_in_group"):
		if body.is_in_group(Globals.GROUP.PLAYER):
			knockback(body)
			
	# Delete the projectile
	delete()

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_projectile(damage, speed, "enemy", (Globals.player_position - global_position).normalized(), acceleration, life_time)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(delta: float) -> void:
	move_dynamically(get_current_velocity())
	spin            (Globals.DIRECTION.CLOCKWISE, 10.0)
	
