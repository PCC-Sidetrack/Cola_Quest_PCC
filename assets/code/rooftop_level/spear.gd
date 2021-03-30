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
export var damage:       int   = 1
export var speed:        float = 9.375
export var acceleration: float = 50.0
export var life_time:    float = 10.0
export var knockback:          = 1
var        _initialized        = false

#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(get_current_velocity())

func initialize() -> void:
	initialize_projectile   (damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_looking                (true)
	set_knockback_multiplier(knockback)
	_initialized = true
	
	# Wait for a little while then set collision to hit enemies as well
	var t: Timer = Timer.new()
	t.set_one_shot(true)
	add_child(t)
	t.start(0.3)
	yield(t, "timeout")
	set_collision_mask_bit(Globals.LAYER.ENEMY, true)
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Entity_collision(body):
	# This is a workaround for an odd glitch. For some reason the player doesn't
	# always detect a collision with projectiles. (Spent hours trying to figure
	# out why but couldn't). So I perform a knockbapck in this collision code instead
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
	if body.is_in_group(Globals.GROUP.ENEMY):
		body.knockback(self)
		deal_damage(body)
	
	# Delete the projectile
	delete()

func _on_Entity_death():
	pass # Replace with function body.

func _on_Entity_health_changed(_change):
	pass # Replace with function body.
