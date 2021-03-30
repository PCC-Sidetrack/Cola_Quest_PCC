#-----------------------------------------------------------------------------#
# File Name:   	MK_Boss.gd                                                    #
# Description: 	Contols the MK_Boss enemy                                    #
# Author:      	Luke Hathcock                                                 #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 20, 2021                                                #
#-----------------------------------------------------------------------------#

extends AI

#-----------------------------------------------------------------------------#
#                           Constant Variables                                #
#-----------------------------------------------------------------------------#
# Holds a reference to the Enemies to be spawned
const PISCES = preload("res://assets//sprite_scenes//mk_scenes//Pisces.tscn")
const ORION = preload("res://assets//sprite_scenes//mk_scenes//MK_Orion.tscn")
const TAURUS = preload("res://assets//sprite_scenes//mk_scenes//Taurus.tscn")

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
export var sent_aim_command: bool = false
export var sent_fire_command: bool = false
# Boolean indicating if the boss if firing it's laser
export var is_firing: bool = false

# Number of seconds between shots
export var fire_cooldown: float = 5.0

# Number of seconds Boss aims
export var fire_aim: float = 3.0

# Number of seconds before Boss fires
export var fire_charge: float = 2.0

# Number fo seconds that the laser is active
export var fire_duration: float = 3.0

# Tells if aiming should be locked
export var lock_aim: bool = false

export var grace_period: float

# Tells where the lasers are aiming
export var aim_location1 = Vector2.ZERO
export var aim_location2 = Vector2.ZERO


export var health: int = 20
export var damage: int = 2

func _ready():
		initialize_enemy(health, damage, 0, 0, 0, false)

func _physics_process(delta):
	if !lock_aim:
		aim_location1 = (Globals.player_position - $MK_Boss_Laser1.global_position) * 2
		aim_location2 = (Globals.player_position - $MK_Boss_Laser2.global_position) * 2
	
	
	if is_firing == true:
		$Aim_Laser1.set_is_casting(false)
		$Aim_Laser2.set_is_casting(false)
		if !sent_fire_command:
			$Aim_Laser1.set_cast_to(aim_location1)
			$Aim_Laser2.set_cast_to(aim_location2)
			$MK_Boss_Laser1.set_cast_to(aim_location1)
			$MK_Boss_Laser2.set_cast_to(aim_location2)
			$MK_Boss_Laser1.set_is_casting(true)
			$MK_Boss_Laser2.set_is_casting(true)
			sent_fire_command = !sent_fire_command
		if grace_period > 0.1:
			if $MK_Boss_Laser1.get_collider().is_in_group(Globals.GROUP.PLAYER):
				$MK_Boss_Laser1.get_collider().knockback(self)
				deal_damage($MK_Boss_Laser1.get_collider())
			if $MK_Boss_Laser2.get_collider().is_in_group(Globals.GROUP.PLAYER):
				$MK_Boss_Laser2.get_collider().knockback(self)
				deal_damage($MK_Boss_Laser2.get_collider())
		grace_period += delta
		fire_duration -= delta
		if fire_duration < 0:
			$MK_Boss_Laser1.set_is_casting(false)
			$MK_Boss_Laser2.set_is_casting(false)
			is_firing     = false
			fire_cooldown = 5
			fire_aim      = 3
			fire_charge   = 2
			fire_duration = 3
			lock_aim      = false
			sent_fire_command = !sent_fire_command
			sent_aim_command = !sent_aim_command
			grace_period = 0
	else:
		if fire_cooldown < 0:
			fire_aim -= delta
			if !sent_aim_command:
				$Aim_Laser1.set_is_casting(true)
				$Aim_Laser2.set_is_casting(true)
				sent_aim_command = !sent_aim_command

			$Aim_Laser2.set_cast_to(aim_location2)
			$Aim_Laser1.set_cast_to(aim_location1)
		if fire_aim < 0:
			fire_charge -= delta
			lock_aim = true
			
		if fire_charge < 0:
			is_firing = true
			
	fire_cooldown -= delta
