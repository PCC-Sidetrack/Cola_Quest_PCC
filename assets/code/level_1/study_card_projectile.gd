#-----------------------------------------------------------------------------#
# File Name:   	3by5_projectile.gd                                            #
# Description: 	Contains the code for directing a 3x5 card projectile         #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Velocity for shooting the projectile
var shoot_velocity: Vector2 = position - Globals.player_position

#-----------------------------------------------------------------------------#
#                               Constructor                                   #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_obeys_gravity(true)
	set_speed(500, 500)
	set_type("projectile")
	set_knockback_multiplier(0.1)
	$AnimatedSprite.play("spin")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Physics process for 3x5 card
func _physics_process(delta: float) -> void:
	var collision = self.move_and_collide(shoot_velocity * delta)
	
	if collision != null:
		queue_free()
