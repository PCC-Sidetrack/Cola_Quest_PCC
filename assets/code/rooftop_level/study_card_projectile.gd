#-----------------------------------------------------------------------------#
# File Name:   study_card_projectile.gd
# Description: The core of every study card projectile
# Author:      Jeff Newell & Andrew Zedwick
# Company:     Sidetrack
# Date:        December 4, 2020
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var damage:       int   = 1
export var speed:        float = 5.0
export var acceleration: float = 50.0
export var life_time:    float = 10.0
export var knockback:    float = 0.6

#-----------------------------------------------------------------------------#
#                               Private Variables                             #
#-----------------------------------------------------------------------------#
# Tracks whether the study card has been initialized yet
var _initialized: bool = false


#-----------------------------------------------------------------------------#
#                              Initialization                                 #
#-----------------------------------------------------------------------------#
#func _ready() -> void:
	#initialize_projectile(damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	#set_knockback_multiplier(knockback)

#-----------------------------------------------------------------------------#
#                            Physics/Process Loop                             #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	if _initialized:
		move_dynamically(get_current_velocity())
		spin            (Globals.DIRECTION.CLOCKWISE, 10.0)

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
# Instead of initializing with the _ready() function, this must be called.
# This method allows initialization to be done at a variable time.
func initialize() -> void:
	initialize_projectile(damage, speed, "enemy", Globals.player_position - global_position, acceleration, life_time)
	set_knockback_multiplier(knockback)
	_initialized = true

#-----------------------------------------------------------------------------#
#                             Signal Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity detects a collision
func _on_KinematicBody2D_collision(body):
	# This is a workaround for an odd glitch. For some reason the player doesn't
	# always detect a collision with projectiles. (Spent hours trying to figure
	# out why but couldn't). So I perform a knockbapck in this collision code instead
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.knockback(self)
		deal_damage(body)
	
	# Delete the projectile
	delete()


func _on_KinematicBody2D_death():
	pass # Replace with function body.

func _on_KinematicBody2D_health_changed(_change):
	pass # Replace with function body.
