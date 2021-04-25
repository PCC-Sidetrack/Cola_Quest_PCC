#-----------------------------------------------------------------------------#
# File Name:   	MK_Boss.gd                                                    #
# Description: 	Contols the MK_Boss enemy                                    #
# Author:      	Luke Hathcock                                                 #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 20, 2021                                                #
#-----------------------------------------------------------------------------#

extends Entity

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
export var sent_aim_command1: bool = false
export var sent_aim_command2: bool = false

export var sent_fire_command1: bool = false
export var sent_fire_command2: bool = false
# Boolean indicating if the boss if firing it's laser
export var is_firing1: bool = false
export var is_firing2: bool = false

# Number of seconds between shots
export var fire_cooldown1: float = 5.0
export var fire_cooldown2: float = 8.0

# Number of seconds Boss aims
export var fire_aim1: float = 3.0
export var fire_aim2: float = 3.0

# Number of seconds before Boss fires
export var fire_charge1: float = 2.0
export var fire_charge2: float = 2.0

# Number fo seconds that the laser is active
export var fire_duration1: float = 4.0
export var fire_duration2: float = 4.0

# Tells if aiming should be locked
export var lock_aim1: bool = false
export var lock_aim2: bool = false

export var grace_period1: float
export var grace_period2: float

# Tells where the lasers are aiming
export var aim_location1 = Vector2.ZERO
export var aim_location2 = Vector2.ZERO

export var health_lost: int = 0

export var phase2: bool = false
export var phase3: bool = false
export var phase4: bool = false

export var health: int = 10
export var damage: int = 1

var start_pos

func _ready():
	initialize_enemy(health, damage, 0, 0, 0, false)
	randomize()
	knockback_enabled = false


func _physics_process(delta):
	var hold_rand = randi()
	
	if !lock_aim1:
		aim_location1 = (Globals.player_position - $MK_Boss_Laser1.global_position) * 2
	if !lock_aim2 && phase2:
		aim_location2 = (Globals.player_position - $MK_Boss_Laser2.global_position) * 2
	
	if get_parent().get_node("ZoomOut/Area2D/CollisionShape2D").activate_boss:
		if is_firing1 == true:
			if !sent_fire_command1:
				$MK_Boss_Laser1.rotation_degrees = 0
				$Aim_Laser1.set_is_casting(false)
				$Aim_Laser1.set_cast_to(aim_location1)
				$MK_Boss_Laser1.set_cast_to(aim_location1)
				$MK_Boss_Laser1.set_is_casting(true)
				sent_fire_command1 = !sent_fire_command1
			if grace_period1 > 0.1:
				if $MK_Boss_Laser1.is_colliding():
					if $MK_Boss_Laser1.get_collider().is_in_group(Globals.GROUP.PLAYER):
						$MK_Boss_Laser1.get_collider().knockback(self)
						deal_damage($MK_Boss_Laser1.get_collider())
			grace_period1 += delta
			fire_duration1 -= delta
			$MK_Boss_Laser1.rotation_degrees += delta * 2
			if fire_duration1 < 0:
				$MK_Boss_Laser1.set_is_casting(false)
				is_firing1         = false
				fire_cooldown1     = 5
				fire_aim1          = 3
				fire_charge1       = 2
				fire_duration1     = 4
				lock_aim1          = false
				sent_fire_command1 = !sent_fire_command1
				sent_aim_command1  = !sent_aim_command1
				grace_period1      = 0
		else:
			if fire_cooldown1 < 0:
				fire_aim1 -= delta
				if !sent_aim_command1:
					$Aim_Laser1.set_is_casting(true)
					sent_aim_command1 = true
					$Laser_Fire1.play()
	
				$Aim_Laser1.set_cast_to(aim_location1)
			if fire_aim1 < 0:
				fire_charge1 -= delta
				lock_aim1 = true
				
			if fire_charge1 < 0:
				is_firing1 = true
				
		if is_firing2 == true:
			if !sent_fire_command2:
				$Aim_Laser2.set_is_casting(false)
				$Aim_Laser2.set_cast_to(aim_location2)
				$MK_Boss_Laser2.set_cast_to(aim_location2)
				$MK_Boss_Laser2.set_is_casting(true)
				sent_fire_command2 = !sent_fire_command2
				$MK_Boss_Laser2.rotation_degrees = 0
			if grace_period2 > 0.1:
				if $MK_Boss_Laser2.is_colliding():
					if $MK_Boss_Laser2.get_collider().is_in_group(Globals.GROUP.PLAYER):
						$MK_Boss_Laser2.get_collider().knockback(self)
						deal_damage($MK_Boss_Laser2.get_collider())
			grace_period2 += delta
			fire_duration2 -= delta
			$MK_Boss_Laser2.rotation_degrees += delta * 10
			if fire_duration2 < 0:
				$MK_Boss_Laser2.set_is_casting(false)
				is_firing2     = false
				fire_cooldown2 = 8
				fire_aim2      = 3
				fire_charge2   = 2
				fire_duration2 = 4
				lock_aim2      = false
				sent_fire_command2 = false
				sent_aim_command2 = false
				grace_period2 = 0
				if phase3 == true:
					hold_rand = randi() % 3 + 1
					if hold_rand == 1:
						pisces_spawn()
					elif hold_rand == 2:
						taurus_spawn()
					else:
						orion_spawn()
		elif phase2:
			if fire_cooldown2 < 0:
				fire_aim2 -= delta
				if !sent_aim_command2:
					$Aim_Laser2.set_is_casting(true)
					sent_aim_command2 = !sent_aim_command2
					$Laser_Fire2.play()
	
				$Aim_Laser2.set_cast_to(aim_location2)
			if fire_aim2 < 0:
				fire_charge2 -= delta
				lock_aim2 = true
				
			if fire_charge2 < 0:
				is_firing2 = true
	
		fire_cooldown1 -= delta
		fire_cooldown2 -= delta
		if health_lost >= 3:
			phase2 = true
		if health_lost >= 6:
			phase3 = true
			
			
func pisces_spawn() -> void:
	# Create, initialize, and add a new spear projectile
	var pisces = PISCES.instance()
	var rand_num = randi() % 3 + 1
	get_node("/root").add_child(pisces)
	if rand_num == 1:
		pisces.global_position = $Pisces_Spawn1.global_position
	if rand_num == 2:
		pisces.global_position = $Pisces_Spawn2.global_position
	if rand_num == 3:
		pisces.global_position = $Pisces_Spawn3.global_position
#	pisces.initialize()

func taurus_spawn() -> void:
	# Create, initialize, and add a new spear projectile
	var taurus = TAURUS.instance()
	get_node("Taurus_Spawn").add_child(taurus)
	taurus.global_position = $Taurus_Spawn.global_position
#	taurus.initialize()

func orion_spawn() -> void:
	# Create, initialize, and add a new spear projectile
	var orion = ORION.instance()
	get_node("Orion_Spawn").add_child(orion)
	orion.global_position = $Orion_Spawn.global_position
#	orion.initialize()


func _on_MK_Boss_health_changed(ammount):
	if health > 0:
		flash_damaged(10)
	health_lost -= ammount
	get_parent().get_node("player/game_UI").on_boss_health_changed(health, health - health_lost)
	$Sword_Hit.play()


func _on_MK_Boss_death():
	var timer: Timer = Timer.new()
	
	set_collision_mask(0)
	set_collision_layer(0)

	timer.set_one_shot(true)
	add_child(timer)
	death_anim (25,  0.04)
	timer.start(25 * 0.04)
	yield(timer, "timeout")
	
	Globals.stop_highscore_timer()
	var game_ui = Globals.player.get_node("game_UI")
	var score = Globals.calculate_highscore(game_ui.get_cola_count(), Globals.get_highscore_timer(), game_ui.get_respawn_count())
	
	Globals.update_highscore_file_from_local()
	
	if Globals.get_highscore_dictionary().makenzie < score:
		Globals.update_mk_score(score)
	
	game_ui.on_player_level_cleared()
	queue_free()
