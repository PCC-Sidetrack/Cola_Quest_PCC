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
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Speed
export var movement_speed:    float   = 5.0
export var acceleration:      float   = 30.0
export var jump_velocity:     float   = 0.0

export var health:            int     = 1
export var damage:            int     = 1

export var obeys_gravity:     bool    = true

export var initial_direction: Vector2 = Vector2.RIGHT

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# The direction the enemy is moving
var _direction: Vector2 = initial_direction

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy           (health, damage, movement_speed, acceleration, jump_velocity, obeys_gravity)
	set_sprite_facing_direction(Globals.DIRECTION.LEFT)
	set_auto_facing            (true)
	
	$AnimatedSprite.play("run")
	
#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	move_dynamically(_direction)
	
	# Change the direction if the entity hits a wall
	if is_on_wall():
		_direction = -_direction
		

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
func _on_S7_running_eagor_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$CollisionShape2D.disabled = true
	timer.set_one_shot(true)
	add_child(timer)
	
	$sword_hit.play()
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()

func _on_S7_running_eagor_health_changed(ammount):
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)
