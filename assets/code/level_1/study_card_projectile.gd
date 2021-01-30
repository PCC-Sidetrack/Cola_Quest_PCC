#-----------------------------------------------------------------------------#
# File Name:   study_card_projectile.gd
# Description: The core of every study card projectile
# Author:      Jeff Newell & Andrew Zedwick
# Company:     Sidetrack
# Date:        December 4, 2020
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 1
export var speed:        float = 5.0
export var acceleration: float = 50.0
export var life_time:    float = 10.0


#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_projectile(damage, speed, "enemy", (Globals.player_position - global_position).normalized(), acceleration, life_time)
	set_knockback_multiplier(0.6)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(get_current_velocity())
	spin            (Globals.DIRECTION.CLOCKWISE, 10.0)
	

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_KinematicBody2D_collision(body):
	# This is a workaround for an odd glitch. For some reason the player doesn't
	# always detect a collision with projectiles. (Spent hours trying to figure
	# out why but couldn't). So I perform a knockbapck in this collision code instead
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
	
	# Delete the projectile
	delete()


func _on_KinematicBody2D_death():
	pass # Replace with function body.

func _on_KinematicBody2D_health_changed(_change):
	pass # Replace with function body.
