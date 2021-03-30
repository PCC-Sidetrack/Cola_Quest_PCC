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
export var jump_speed:   float = 850
export var speed:        float = 16.0

var jump_delay: float = randf()

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, speed, acceleration, jump_speed, true, true)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_knockback_multiplier   (2.0)
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(Vector2.DOWN)
	
	if global_position.direction_to(Globals.player_position).x >= 0:
		set_direction_facing(Globals.DIRECTION.LEFT)
	else:
		set_direction_facing(Globals.DIRECTION.RIGHT)
	
	if $Timer.is_stopped():
		$Timer.start(1.5)
	
	if is_on_floor():
		$Sprites/Jump.visible      = false
		$Sprites/ReadyJump.visible = true

func _on_Area2D_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group(Globals.GROUP.PLAYER):
		knockback(parent)

func _on_Timer_timeout() -> void:
	$Sprites/Jump.visible      = true
	$Sprites/ReadyJump.visible = false
	jump(rand_range(0.6, 1.0))
