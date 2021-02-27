#-----------------------------------------------------------------------------#
# File Name:   	orion.gd                                                      #
# Description: 	Controls the throwing of the spear projectile and animations  #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 21th, 2020                                           #
#-----------------------------------------------------------------------------#

extends EntityV2

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
#const SPEAR = preload("res://assets//sprite_scenes//level_1//spear.tscn")


#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:     bool  = true
# Number of seconds before Orion throws a spear
export var throw_cooldown: float = 2.0

export var health: int = 10
export var damage: int = 2

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since Orion last threw a spear
var _throw_update_time: float = 0.0
# Number of seconds since Orion began playing his throwing animation
var _throw_anim_time: 	float = throw_cooldown / 2


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	
	initialize_enemy(health, damage, 0.0, 0.0)
	
	$AnimatedSprite.play("idle")

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_throw_update_time += delta
		
		if _throw_update_time >= throw_cooldown:
			# Animate orion to throw the spear
			$AnimatedSprite.play("throw")
			if $AnimatedSprite.animation == "throw" and $AnimatedSprite.frame >= $AnimatedSprite.frames.get_frame_count("throw") - 3:
				_spawn_spear()
		elif $AnimatedSprite.animation != "idle":
			$AnimatedSprite.play("idle")

# Spawns and propels a spear
func _spawn_spear() -> void:
	# Create, initialize, and add a new spear projectile
	var spear = load("res://assets//sprite_scenes//level_1//spear.tscn").instance()
	$spear_spawn.add_child(spear)
	
	# Reset the _throw_update time now that the spear has been spawned
	_throw_update_time = 0.0
