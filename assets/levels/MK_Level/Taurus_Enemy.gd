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

export  var health:            int     = 1
export  var damage:            int     = 1

export  var obeys_gravity:     bool    = true

export  var initial_direction: Vector2 = Vector2.RIGHT

export onready var EdgeLooker          = get_node("EdgeLooker")
export onready var ChargeLooker        = get_node("ChargeLooker")
export onready var DmgPlayer           = get_node("DmgPlayer")

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: Vector2 = initial_direction

var _sound_timer: float = 10.0
#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, movement_speed, acceleration, jump_velocity, obeys_gravity)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("move")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	if !EdgeLooker.is_colliding():
		_direction = -_direction
		print("Changing dir")
		if EdgeLooker.get_cast_to() == Vector2(-35, 25):
			EdgeLooker.set_cast_to(Vector2(35, 25))
			ChargeLooker.set_cast_to(Vector2(180, 0))
			DmgPlayer.set_cast_to(Vector2(20, 0))
		else:
			EdgeLooker.set_cast_to(Vector2(-35, 25))
			ChargeLooker.set_cast_to(Vector2(-180, 0))
			DmgPlayer.set_cast_to(Vector2(-20, 0))
	
	_sound_timer += _delta
	if ChargeLooker.is_colliding():
		set_speed(10)
		set_knockback_multiplier(2)
		if _sound_timer > 2:
			play_sound()
			_sound_timer = 0.0
	else:
		set_speed(3)
		set_knockback_multiplier(1)
		
	if DmgPlayer.get_collider():
		deal_damage(DmgPlayer.get_collider())
		DmgPlayer.get_collider().knockback(self)
	
	move_dynamically(_direction)
	# Change the direction if the entity hits a wall
	if is_on_wall():
		_direction = -_direction
		if EdgeLooker.get_cast_to() == Vector2(-35, 25):
			EdgeLooker.set_cast_to(Vector2(35, 25))
			ChargeLooker.set_cast_to(Vector2(180, 0))
			DmgPlayer.set_cast_to(Vector2(20, 0))
		else:
			EdgeLooker.set_cast_to(Vector2(-35, 25))
			ChargeLooker.set_cast_to(Vector2(-180, 0))
			DmgPlayer.set_cast_to(Vector2(-20, 0))
			
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func play_sound():
	var j = 1.0
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	$AudioStreamPlayer2D.play()
	t.start()
	yield(t, "timeout")
	$AudioStreamPlayer2D.stop()


func _on_Taurus1_health_changed(ammount):
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)

func _on_Taurus1_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.disabled = true

	timer.set_one_shot(true)
	add_child(timer)
	
	# Add an audio pitch fade out
	$sword_hit.play()
	$Tween.interpolate_property($AudioStreamPlayer2D, "pitch_scale", $AudioStreamPlayer2D.pitch_scale, 0.01, 50 * 0.04)
	$Tween.start()
	
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()
