#-----------------------------------------------------------------------------#
# File Name:   Taurus_Enemy.gd
# Description: A charging enemy
# Author:      Luke Hathcock
# Company:     Sidetrack
# Date:        March 6, 2021
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                               Inheiritance                                  #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Speed
export  var movement_speed:    float   = 3.0
export  var acceleration:      float   = 25.0
export  var jump_velocity:     float   = 0.0

export  var health:            int     = 2
export  var damage:            int     = 1

export  var obeys_gravity:     bool    = true

export  var initial_direction: Vector2 = Vector2.RIGHT

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: Vector2 = initial_direction
var check_health = health - 1

var _sound_timer: float = 10.0
#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, movement_speed, acceleration, jump_velocity, obeys_gravity)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("move")
	$healthbar.max_value = health
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	if !$EdgeLooker.is_colliding():
		_direction = -_direction
		$EdgeLooker.scale.x   *= -1
		$ChargeLooker.scale.x *= -1
	
	_sound_timer += _delta
	if $ChargeLooker.is_colliding():
		set_speed(10)
		set_knockback_multiplier(2)
		if _sound_timer > 2:
			play_sound($TaurusCharge, 2)
			_sound_timer = 0.0
	else:
		set_speed(3)
		set_knockback_multiplier(1)
	
	
	move_dynamically(_direction)
	# Change the direction if the entity hits a wall
	if is_on_wall():
		_direction = -_direction
		$EdgeLooker.scale.x   *= -1
		$ChargeLooker.scale.x *= -1

	
func play_sound(var sound, var length):
	var t = Timer.new()
	t.set_wait_time(length)
	t.set_one_shot(true)
	self.add_child(t)
	sound.play()
	t.start()
	yield(t, "timeout")
	sound.stop()
	
func spin_sprite():
	var timer: Timer = Timer.new()
	for i in 100:
		timer.set_one_shot(true)
		add_child(timer)
		timer.start(0.01)
		yield(timer, "timeout")
		$AnimatedSprite.rotation_degrees = $AnimatedSprite.rotation_degrees + 30
		i += 1
	
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_Taurus_collision(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		if check_health:
			body.knockback(self)
			deal_damage(body)


func _on_Taurus1_health_changed(amount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if check_health:
		play_sound($Hurt, .75)
		flash_damaged(10)
		check_health -= amount
	
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

func _on_Taurus1_death():
	var timer: Timer = Timer.new()
	$DmgPlayer.set_collision_mask(0)
	set_collision_mask(0)
	set_collision_layer(0)
	spin_sprite()
	timer.set_one_shot(true)
	add_child(timer)
	
	play_sound($Hurt, .75)
	
	death_anim (25, 0.01)
	timer.start(25 * 0.04)
	yield(timer, "timeout")
	queue_free()


func _on_DmgPlayer_body_entered(body):
	if body.is_in_group(Globals.GROUP.PLAYER):
		if check_health:
			body.knockback(self)
			deal_damage(body)

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 
