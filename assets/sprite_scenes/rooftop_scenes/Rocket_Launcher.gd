#-----------------------------------------------------------------------------#
# File Name:   	orion.gd                                                      #
# Description: 	Controls the throwing of the spear projectile and animations  #
# Author:      	Andrew Zedwick (mostly) & Jeff Newell                         #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 21th, 2020                                           #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
const SPEAR = preload("res://assets/sprite_scenes/rooftop_scenes/rocket.tscn")


#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:     bool  = true
# Number of seconds before Orion throws a spear
export var throw_cooldown: float = 4.0

export var health: int = 3
export var damage: int = 1

#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since Orion last threw a spear
var _throw_update_time: float = 0.0


#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	initialize_enemy(health, damage, 0.0, 0.0)

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_throw_update_time += delta
		
		if _throw_update_time >= throw_cooldown:
				_spawn_spear()

# Spawns and propels a spear
func _spawn_spear() -> void:
	# Create, initialize, and add a new spear projectile
	var spear = SPEAR.instance()
	get_node("/root").add_child(spear)
	spear.global_position = $spear_spawn.global_position
	spear.initialize()
	
	# Reset the _throw_update time now that the spear has been spawned
	_throw_update_time = 0.0
	
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#

