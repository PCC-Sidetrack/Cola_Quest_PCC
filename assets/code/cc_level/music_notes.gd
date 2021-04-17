#-----------------------------------------------------------------------------#
# File Name:    music_notes.gd
# Description: 
# Author:       Sephrael Lumbres
# Company:      Sidetrack
# Last Updated: April 15, 2021                                                #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 1
export var speed:        float = 8
export var acceleration: float = 100
export var life_time:    float = 10.0
export var is_correct:   bool  = false

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
func initialize() -> void:
	initialize_projectile      (damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_collision_mask_bit(Globals.LAYER.ENEMY, false)
	set_collision_mask_bit(Globals.LAYER.WORLD, false)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(Globals.player_position - global_position)
	$AnimatedSprite.play("fly")


func _on_quarter_note_collision(body) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
		
		# Delete the projectile
		delete()


func _on_sword_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group(Globals.GROUP.PLAYER) and is_correct:
		delete()
	elif not is_correct:
		area.get_parent().knockback(self)
		deal_damage(area.get_parent())
