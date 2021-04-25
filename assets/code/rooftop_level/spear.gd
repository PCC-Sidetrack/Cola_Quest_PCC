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
export var knockback:          = 2.0
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
	initialize_projectile      (damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_looking                (true)
	set_knockback_multiplier   (knockback)
	_initialized = true
	
	# Wait for a little while then set collision to hit enemies as well
	var t: Timer = Timer.new()
	t.set_one_shot(true)
	add_child(t)
	t.start(0.3)
	yield(t, "timeout")
	set_collision_mask_bit(Globals.LAYER.ENEMY, true)
	t.queue_free()
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_Entity_death():
	pass # Replace with function body.

func _on_Entity_health_changed(_change):
	pass # Replace with function body.


func _on_hitbox_body_entered(body: Node) -> void:
	if (body.is_in_group(Globals.GROUP.PLAYER) or body.is_in_group(Globals.GROUP.ENEMY)) and body != self:
		body.take_damage(damage)
		_knockback_old(body)
		
	if body != self:
		delete()


func _on_VisibilityEnabler2D_screen_exited() -> void:
	delete()


func _on_delay_body_exited(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.ENEMY):
		$hitbox/CollisionShape2D.set_deferred("disabled", false)
		$delay/CollisionShape2D.set_deferred("disabled", true)
