extends Node

onready var red_rectangles     = $glitch_backgruond/red_rectangles
onready var text_1             = $glitch_backgruond/text_1
onready var text_2             = $glitch_backgruond/text_2
onready var light_levers       = $lights/light_levers
onready var l_section_1        = $lights/l_section_1
onready var l_section_2        = $lights/l_section_2_spiders
onready var l_section_3        = $lights/l_section_3
onready var l_section_4        = $lights/l_section_4_bats
onready var light_tween        = $lights/light_tween
onready var error_zone         = $error_zone
onready var camera             = $player/Camera2D
onready var camera_tween       = $player/Camera2D/Tween
onready var shake_timer        = $world_timers/shake_timer
onready var section_1_borders  = $section_1/section_1_borders
onready var area_trigger       = $Area_triggers
onready var error_text_type    = $error_zone/error_text
onready var instructions_text  = $error_zone/instructions
onready var instructions_timer = $error_zone/instructions_timeout
onready var er_zone_ani_player = $error_zone/AnimationPlayer
onready var bugs_left          = $error_zone/bugs_left
onready var bugs_left_text     = $error_zone/bugs_left/bugs_left_text
onready var number_remaining   = $error_zone/bugs_left/number_remaining
onready var spider_instance    = preload("res://assets/levels/AC_Level/instanced_objects/spider.tscn")
onready var bat_instance       = preload("res://assets/levels/AC_Level/instanced_objects/bat.tscn")
onready var spawn_in_effect    = preload("res://assets/levels/AC_Level/assets/sprites/particles/spawn_in.tscn")
onready var section_1_spawner  = $section_1/spawner
onready var enemy_respawn_delay = $world_timers/enemy_respawn_delay
onready var enemy_spawn_in_delay = $world_timers/enemy_spawn_in
onready var lever_hit            = $sounds/lever_hit
onready var drsparks             = $AI/Teachers/sparks/mr_spark
onready var mrstemen             = $AI/Teachers/stemen/mr_stemen
onready var spark_animation      = $AI/Teachers/sparks/sparks_animation
onready var stemen_aniamtion     = $AI/Teachers/stemen/stemen_ani
onready var cannon               = $cannon_stationary/cannon

var _current_section  = l_section_2
var shake_amount      = 3
var enemies_remaining = 999

func _ready():
	$AI/Teachers/sparks/force_field.visible                  = true
	$AI/Teachers/sparks/transition/transition_screen.visible = false
	$AI/Teachers/sparks/drsparks.visible                     = false
	$AI/Teachers/stemen/mr_stemen.modulate                   = Color(0.341176, 0.294118, 0.196078)
	camera.current = true
	drsparks.play("stuck")
	drsparks.modulate = Color.white
	area_trigger.get_node("lever_1").set_deferred("monitoring", false)
	area_trigger.get_node("lever_2").set_deferred("monitoring", false)
	$section_1.visible     = true
	l_section_1.visible    = true
	l_section_2.visible    = false
	l_section_3.visible    = false
	l_section_4.visible    = false
	red_rectangles.visible = false
	text_1.visible         = false 
	text_2.visible         = false 
	error_zone.visible     = false
	section_1_borders.disable() 
	$sounds/background_ambiant.play()
	$sounds/music_idle.play()


func _physics_process(_delta):
	bugs_left_text.set_text("Bugs Remaining: ")
	number_remaining.set_text(str(enemies_remaining))
	if shake_timer.time_left > 0:
		_shake()

func _shake():
	$player/Camera2D.set_offset(Vector2( \
	rand_range(-1.0, 1.0) * shake_amount, \
	rand_range(-1.0, 1.0) * shake_amount  \
))
	
func _on_lock_section_spiders_body_entered(body):
	if body == $player:
		enemies_remaining = 15
		instructions_text.set_text("Destroy " + str(enemies_remaining) + " bugs!")
		# Disable last section lights, and enable current section lights
		l_section_1.visible    = false
		l_section_2.visible    = true
		error_zone.rect_position.x = 0
		error_zone.rect_position.y = 0
		$error_zone/bugs_left.rect_position.y = 163.502
		$error_zone/error_text.set_text("stack_error")
		_current_section = l_section_2

		$player/Camera2D.zoom.x = 1.4
		$player/Camera2D.zoom.y = 1.4
		
		# Disable activation area and enable borders
		area_trigger.get_node("lock_section_spiders/activator").set_deferred("disabled", true)
		section_1_borders.enable()
		
		# Tween the camera to the new position
		camera_tween.interpolate_property(camera, "limit_left", $player.position.x , 648, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		camera_tween.interpolate_property(camera, "limit_right", $player.position.x , 1416, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		camera_tween.start()
		yield(camera_tween, "tween_all_completed")
		
		_show_error_zone()
		yield(er_zone_ani_player, "animation_finished")
		_spawn_enemies(spider_instance, section_1_spawner)

func _show_error_zone():
	$sounds/error_sound.play()
	$sounds/siren.play()
	$sounds/music_attack.play()
	$sounds/music_idle.stop()
	enemy_respawn_delay.wait_time = 2
	shake_timer.wait_time         = 2
	shake_timer.start()
	error_zone.visible     = true
	red_rectangles.visible = true
	text_1.visible         = true 
	text_2.visible         = true 
	error_zone.get_node("center_glitch").visible = true
	error_zone.get_node("instructions").visible  = false
	instructions_text.rect_scale.y = 0.5
	bugs_left.visible  = false
	
	error_text_type.visible = true
	yield(shake_timer, "timeout")
	error_text_type.visible = false

	error_zone.get_node("center_glitch").visible = false
	error_zone.get_node("instructions").visible  = true
	
	instructions_timer.start()
	yield(instructions_timer, "timeout")
	er_zone_ani_player.play("transitino_instructions")	
	yield(er_zone_ani_player, "animation_finished")
	bugs_left.visible = true

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
			if enemy_type_instance == spider_instance:
				match enemies_remaining:
					12:
						enemy_respawn_delay.wait_time = 1.5
					7: 
						enemy_respawn_delay.wait_time = 1
					5:
						enemy_respawn_delay.wait_time = .5
			if enemy_type_instance == bat_instance:
				match enemies_remaining:
					14:
						enemy_respawn_delay.wait_time = 1.5
					9: 
						enemy_respawn_delay.wait_time = 1
					7:
						enemy_respawn_delay.wait_time = .5

func _on_enemies_left_body_exited(body):
	if body.is_in_group("enemy") and enemies_remaining >= 0:
		enemies_remaining -= 1
		bugs_left.get_node("Tween").interpolate_property(number_remaining, "rect_scale", Vector2(1.3,0.9), Vector2(0.895,0.431), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		bugs_left.get_node("Tween").start()
		if enemies_remaining == 0:
			match _current_section:
				l_section_2:
					_enemies_cleared(l_section_2)
				l_section_4:
					_enemies_cleared(l_section_4)

func _enemies_cleared(l_section_type):
	$sounds/siren.stop()
	$sounds/music_attack.stop()
	shake_timer.wait_time = .5
	shake_amount          = 5
	shake_timer.start()

	yield(shake_timer, "timeout")
	bugs_left.visible      = false
	red_rectangles.visible = false
	text_1.visible         = false 
	text_2.visible         = false 
	
	for lights in l_section_type.get_children():
			light_tween.interpolate_property(lights, "color", Color.red, Color.black, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			light_tween.start()
	
	for lever in light_levers.get_children():
		light_tween.interpolate_property(lever, "color", Color.black, Color.white, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		light_tween.start()
	
	match l_section_type:
		l_section_2:
			area_trigger.get_node("lever_1").set_deferred("monitoring", true)
		l_section_4:
			area_trigger.get_node("lever_2").set_deferred("monitoring", true)
			yield(get_tree().create_timer(3), "timeout")
			cannon.disable_turret()
			$player.visible = true
			yield(get_tree().create_timer(.5), "timeout")
			Globals.game_locked = false

func _section_cleared(l_section_type):
	$sounds/music_idle.play()
	shake_timer.wait_time = .5
	shake_amount          = 5
	shake_timer.start()
	yield(shake_timer, "timeout")
	section_1_borders.disable()
	for lights in l_section_type.get_children():
		light_tween.interpolate_property(lights, "color", Color.black, Color.white, .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		light_tween.start()
	error_zone.visible = false
	


func _on_lever_1_area_entered(area):
	if area.is_in_group("hitbox"):
		lever_hit.play()
		_section_cleared(l_section_2)
		spark_animation.play("zoom_in")
		area_trigger.get_node("lever_1").set_deferred("monitoring", false)

func _on_lever_2_area_entered(area):
	if area.is_in_group("hitbox"):
		lever_hit.play()
		_section_cleared(l_section_4)
		stemen_aniamtion.play("stemen_freed")
		area_trigger.get_node("lever_2").set_deferred("monitoring", false)
		$lights/end_door_light.visible = true

func _on_section_spikes_body_entered(body):
	for lever in light_levers.get_children():
		light_tween.interpolate_property(lever, "color", Color.white, Color.black, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		light_tween.start()
	if body == $player:
		$Area_triggers/section_spikes/spikes_animation.play("fade_in")
		area_trigger.get_node("section_spikes").set_deferred("monitoring", false)

func _on_lock_section_bats_body_entered(body):
	if body == $player:
		$player.visible = false
		Globals.game_locked = true
		cannon.enable_turret()
		
		enemies_remaining = 16
		instructions_text.set_text("Destroy " + str(enemies_remaining) + " bugs!")
		# Disable last section lights, and enable current section lights
		l_section_2.visible = false
		l_section_3.visible = false
		l_section_4.visible = true

		$error_zone/error_text.set_text("http != port 08")
		$section_1.rect_position.x = 2617.102
		error_zone.rect_position.x = 1860
		error_zone.rect_position.y = 0
		$error_zone/bugs_left.rect_position.y = 40
		_current_section = l_section_4
		
		$player/Camera2D.zoom.x = 1.4
		$player/Camera2D.zoom.y = 1.4
		# Disable activation area and enable borders

		area_trigger.get_node("lock_section_bats/activator").set_deferred("disabled", true)
		
		section_1_borders.enable()
		
		# Tween the camera to the new position
		camera_tween.interpolate_property(camera, "limit_left", $player.position.x , 2501, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		camera_tween.interpolate_property(camera, "limit_right", $player.position.x , 3281, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		camera_tween.start()
		yield(camera_tween, "tween_all_completed")
		
		_show_error_zone()
		yield(er_zone_ani_player, "animation_finished")
		_spawn_enemies(bat_instance, section_1_spawner)


func _on_damage_zone_body_entered(body):
	if body.is_in_group("enemy"):
		Globals.player.take_damage(2)
		body.take_damage(1000)

func _on_game_lock():
	Globals.game_locked = true

func _on_game_unlock():
	Globals.game_locked = false

func _on_next_scene_area_entered(area):
	if area.is_in_group("hitbox"):
		$sounds/door_transition.play()
		yield($sounds/door_transition, "finished")
		SceneFade.change_scene("res://assets/levels/AC_Level/main_scenes/AC_level_grass.tscn", 'fade')
