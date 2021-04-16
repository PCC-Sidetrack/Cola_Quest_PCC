extends Node2D
onready var bat_instance       = preload("res://assets/levels/AC_Level/instanced_objects/bat.tscn")
onready var spawn_in_effect    = preload("res://assets/levels/AC_Level/assets/sprites/particles/spawn_in.tscn")
onready var enemy_respawn_delay = $world_timers/enemy_respawn_delay
onready var enemy_spawn_in_delay = $world_timers/enemy_spawn_in
onready var enemy_spawn         = $enemy_spawn
var enemies_remaining = 0

func _physics_process(_delta):
	pass


func _spawn_enemies(enemy_type_instance, spawner_section):
	while enemies_remaining >= 0:
		for spawn_point in spawner_section.get_children():

			var spawn_in  = spawn_in_effect.instance()
			var enemy_type = enemy_type_instance.instance()

			enemy_type.global_position = spawn_point.position
			spawn_in.global_position   = enemy_type.position
			
			if enemies_remaining == 0 or enemies_remaining < 0:
				return
			
			spawn_point.add_child(spawn_in)
			enemy_spawn_in_delay.start()
			yield(enemy_spawn_in_delay, "timeout")
			
			$sounds/enemy_spawn_in.play()
			spawn_point.add_child(enemy_type)
			enemy_respawn_delay.start()
			yield(enemy_respawn_delay, "timeout")
			if enemy_type_instance == bat_instance:
				match enemies_remaining:
					14:
						enemy_respawn_delay.wait_time = 1.5
					9: 
						enemy_respawn_delay.wait_time = 1
					7:
						enemy_respawn_delay.wait_time = .5

func _bats_attacking():
	enemies_remaining = 20
	_spawn_enemies(bat_instance, enemy_spawn)
