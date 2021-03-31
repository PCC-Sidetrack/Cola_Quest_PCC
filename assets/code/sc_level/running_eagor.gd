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
export var acceleration: float = 10.0
export var damage:       int   = 1
export var health:       int   = 2
export var jump_speed:   float = 0.05
export var speed:        float = 5.0

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	var instructions = [
		distance (Vector2.RIGHT, 6.0),
		end_point(global_position),
	]
	initialize_instructions(instructions, true)
	
	
	initialize_enemy           (health, damage, speed, acceleration, jump_speed)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_smooth_movement        (false)
	set_knockback_multiplier   (2.0)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("run")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
# warning-ignore:return_value_discarded
	move()


func _on_Area2D_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group(Globals.GROUP.PLAYER):
		knockback(parent)
