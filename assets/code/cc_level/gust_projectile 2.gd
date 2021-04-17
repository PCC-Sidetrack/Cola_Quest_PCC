#-----------------------------------------------------------------------------#
# File Name:   gust_projectile.gd
# Description: 
# Author:      Sephrael Lumbres
# Company:     Sidetrack
# Last Updated: March 29, 2021                                                #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 1
export var speed:        float = 8
export var acceleration: float = 100
export var life_time:    float = 10.0

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func initialize() -> void:
	initialize_projectile      (damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_collision_mask_bit(Globals.LAYER.ENEMY, false)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(Globals.player_position - global_position)
	$AnimatedSprite.play("gust_attack")

#-----------------------------------------------------------------------------#
#                             Signal Functions                                #
#-----------------------------------------------------------------------------#
func _on_gust_projectile_collision(body) -> void:
	
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
	
	# Delete the projectile
	delete()

func _on_sword_hitbox_area_entered(_area: Area2D) -> void:
	if _area.get_parent().is_in_group(Globals.GROUP.PLAYER):
		delete()
	