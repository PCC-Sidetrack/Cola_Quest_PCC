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
var        time_alive          = 20

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(get_current_velocity())
	time_alive -= _delta
	if time_alive < 0:
		queue_free()
	

# Instead of initializing the spear when the on _ready(), allow the timing of
# initialization to be custimized
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
	t.queue_free()

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_Area2D_body_entered(body):
	if (body.is_in_group(Globals.GROUP.PLAYER) or body.is_in_group(Globals.GROUP.ENEMY)):
		body.take_damage(damage)
		_knockback_old(body)
		
	if body != self:
		delete()
