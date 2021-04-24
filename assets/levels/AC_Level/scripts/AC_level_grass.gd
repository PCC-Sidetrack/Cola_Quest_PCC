extends Node2D
onready var bat_instance       = preload("res://assets/levels/AC_Level/instanced_objects/bat_grass.tscn")
onready var spawn_in_effect    = preload("res://assets/levels/AC_Level/assets/sprites/particles/spawn_in.tscn")
onready var enemy_respawn_delay = $world_timers/enemy_respawn_delay
onready var plane                = $adkins_plane
onready var enemy_spawn         = $enemy_spawn

func _physics_process(_delta):
	$error_zone2/error_zone/bugs_left/bugs_left_text.set_text("Bugs Remaining: ")
	$error_zone2/error_zone/bugs_left/number_remaining.set_text(str($error_zone2/error_zone.enemies_remaining))


func _ready():
	$player.load_from_transition()
	Globals.player.has_spawn_points = false
	
	$player/player_cam.current = true
	#$player/game_UI.on_no_checkpoints()
	$StaticBody2D2/Light2D2.visible = false
	$door_activator.set_deferred("monitoring", false)
	$drhowell/Light2D.visible = true
	$background/Light2D.visible = false
	enemy_respawn_delay.wait_time = 1
	$error_zone2.visible = false
	$error_zone2/error_zone.error_zone_init(70, "air_has_ocurred", $world_timers/shake_timer)
	$plane_transitions/black_screen.visible = false

	$background/PL1c_blue_sky_clouds.material.set("shader_param/speed", .01)
	$background/PL1b_blue_sky_clouds.material.set("shader_param/speed", .02)
	$background/PL1b_blue_sky_clouds2.material.set("shader_param/speed", .02)

func _spawn_enemies(enemy_type_instance, spawner_section):
	while $error_zone2/error_zone.enemies_remaining >= 0:
		for spawn_point in spawner_section.get_children():

			var spawn_in  = spawn_in_effect.instance()
			var enemy_type = enemy_type_instance.instance()

			enemy_type.global_position = spawn_point.position
			spawn_in.global_position   = enemy_type.position
			
			if $error_zone2/error_zone.enemies_remaining == 0 or $error_zone2/error_zone.enemies_remaining < 0:
				return
			
			spawn_point.add_child(spawn_in)
#			enemy_spawn_in_delay.start()
#			yield(enemy_spawn_in_delay, "timeout")
			
			$sounds/enemy_spawn_in.play()
			spawn_point.add_child(enemy_type)
			enemy_respawn_delay.start()
			enemy_type.attack_plane(plane)
			yield(enemy_respawn_delay, "timeout")
			

			
			if enemy_type_instance == bat_instance:
				match $error_zone2/error_zone.enemies_remaining:
					65:
						enemy_respawn_delay.wait_time = 0.7
					50: 
						enemy_respawn_delay.wait_time = 0.5
					30:
						enemy_respawn_delay.wait_time = 0.3

func _bats_attacking():
	_spawn_enemies(bat_instance, enemy_spawn)


func _on_hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		Globals.player.take_damage(2)
		body.take_damage(1000)
		

func _on_plane_activator_area_entered(area):
	if area.is_in_group("hitbox"):
		$plane_activator.set_deferred("monitoring", false)
		$drhowell/Light2D.visible = false
		_transition_to_plane()

func _transition_to_plane():
	Globals.game_locked = true
	$plane_transitions/AnimationPlayer.play("transition_to")
	$adkins_plane/enter_plane.play()
	yield($plane_transitions/AnimationPlayer, "animation_finished")
	$player/player_cam/CanvasLayer/Control.visible = false
	$adkins_plane/plane_flying.play()
	$adkins_plane.enable_plane()
	$error_zone2/error_zone.activate_error_zone()
	$error_zone2.visible = true
	$error_zone2/error_zone/ColorRect2.visible = true
	$background/Light2D.visible = true
	yield($error_zone2/error_zone/AnimationPlayer, "animation_finished")
	$error_zone2/error_zone/ColorRect2.visible = false


	_bats_attacking()


func fast_clouds():
	$background/PL1c_blue_sky_clouds.material.set("shader_param/speed", .05)
	$background/PL1b_blue_sky_clouds.material.set("shader_param/speed", .1)

func slow_clouds():
	$background/PL1c_blue_sky_clouds.material.set("shader_param/speed", .01)
	$background/PL1b_blue_sky_clouds.material.set("shader_param/speed", .02)

func _on_error_zone_body_left(body):
	if body.is_in_group("enemy"):
		$error_zone2/error_zone.enemies_remaining -= 1
		if $error_zone2/error_zone.enemies_remaining <= 0:
			$error_zone2/error_zone/bugs_left.visible = false
			$world_timers/enemies_alive.start()
			yield($world_timers/enemies_alive, "timeout")
			$adkins_plane.disable_plane()
			$adkins_plane/plane_flying.stop()
			$plane_transitions/AnimationPlayer.play("transition_out")
			$background/Light2D.visible = false
			$door_activator.set_deferred("monitoring", true)
			$StaticBody2D2/Light2D2.visible = true
			$error_zone2/error_zone.deactive_error_zone()
			Globals.game_locked = true
			yield($plane_transitions/AnimationPlayer, "animation_finished")
			$drhowell/howell_animation.play("free_howell")
			yield($drhowell/howell_animation, "animation_finished")
			Globals.game_locked = false

func _on_door_activator_area_entered(area):
	if area.is_in_group("hitbox"):
		$player.prepare_transition()
		$adkins_plane/enter_plane.play()
		SceneFade.change_scene("res://assets/levels/AC_Level/main_scenes/AC_level_boss.tscn",'fade')
		queue_free()
