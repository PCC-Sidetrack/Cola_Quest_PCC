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
export var acceleration: float = 20.0
export var damage:       int   = 1
export var health:       int   = 2
export var jump_speed:   float = 0.0
export var speed:        float = 7.0

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, speed, acceleration, jump_speed, false, true)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_smooth_movement        (true)
	set_knockback_multiplier   (3.0)
	set_auto_facing            (true)
	$AnimationPlayer.play("fly")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(global_position.direction_to(Globals.player_position))
	$flaping.pitch_scale = rand_range(1.2, 1.6)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# This detects the player and causes damage
func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		_knockback_old(body)
		body._knockback_old(self)

# When the eagor dies
func _on_flying_eagor_death() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.monitoring = false
	
	$sword_hit.play()
	death_anim (5,  0.1)
	yield(get_tree().create_timer(5 * 0.1), "timeout")
	queue_free()

# When the eagor gets hit
func _on_flying_eagor_health_changed(ammount) -> void:
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
	get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false
