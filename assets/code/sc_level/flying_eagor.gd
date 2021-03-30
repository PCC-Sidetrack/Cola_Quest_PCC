#-----------------------------------------------------------------------------#
# File Name:   running_eagor.gd
# Description: A basic enemy with basic AI
# Author:      Jeff Newell
# Company:     Sidetrack
# Date:        October 6, 2020
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                               Inheiritance                                  #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
export var acceleration: float = 7.5
export var damage:       int   = 1
export var health:       int   = 2
export var jump_speed:   float = 0.0
export var speed:        float = 16.0

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, speed, acceleration, jump_speed, false, true)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_smooth_movement        (true)
	set_knockback_multiplier   (2.0)
	set_auto_facing            (true)
	$AnimationPlayer.play("fly")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(global_position.direction_to(Globals.player_position))


func _on_Area2D_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group(Globals.GROUP.PLAYER):
		knockback(parent)
