#-----------------------------------------------------------------------------#
# File Name:   	3by5_projectile.gd                                            #
# Description: 	Contains the code for directing a 3x5 card projectile         #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

extends KinematicBody2D

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Velocity at which the projectile moves
var velocity:       Vector2 = Vector2.ZERO
# Velocity for shooting the projectile
var shoot_velocity: Vector2 = Vector2(800.0, 400.0)

#-----------------------------------------------------------------------------#
#                               Constructor                                   #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	set_physics_process(false)

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Launches the projectile
func launch(direction: float) -> void:
	# remove the projectile so it can be added again in the correct location
	var temp:  Transform2D = global_transform
	var scene: Node		   = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = shoot_velocity * Vector2(direction, 1)
	set_physics_process(true)
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Physics process for 3x5 card
func _physics_process(delta: float) -> void:
	# TODO: CREATE A GLOBALS CLASS TO HOLD THINGS SUCH AS GRAVITY
	var collision = move_and_collide(Vector2(0.0, 2000.0 * delta))
	
	#if collision != null:
		#_on_impact(collision.normal)

# Deletes the projectile whenever it impacts something
#func _on_impact(normal: Vector2) -> void:
	#get_tree().remove_child(self)
