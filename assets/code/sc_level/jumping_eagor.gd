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
export var speed:        float = 5.0

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

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
# This detects the the players hurtbox and causes damage
# Saved in case we switch to the conventional hitbox/hurtbox system
#func _on_Area2D_area_entered(area: Area2D) -> void:
#	var parent = area.get_parent()
#	if parent.is_in_group(Globals.GROUP.PLAYER) and area.is_in_group("hurtbox"):
#		parent.take_damage(damage)
#		knockback(parent)

func _on_Timer_timeout() -> void:
	$Sprites/Jump.visible      = true
	$Sprites/ReadyJump.visible = false
	jump(rand_range(0.6, 1.0))
	$jump.play()

# This detects the the player and causes damage
func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		_knockback_old(body)
		body._knockback_old(self)

# When the eagor gets hit
func _on_jumping_eagor_health_changed(ammount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# When the eagor dies
func _on_jumping_eagor_death() -> void:
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.monitoring = false
	timer.set_one_shot(true)
	add_child(timer)
	
	$sword_hit.play()
	death_anim (5,  0.1)
	timer.start(5 * 0.1)
	yield(timer, "timeout")
	queue_free()

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 


func _on_VisibilityEnabler2D_screen_entered() -> void:
	$Timer.paused = false


func _on_VisibilityEnabler2D_screen_exited() -> void:
	$Timer.paused = true
