extends Node2D

onready var dean_animations = $dean_philips_boss/boss
onready var attack_floor    = $bike_attacks/floor/bike_attack
onready var attack_third    = $bike_attacks/third_to_top/bike_attack
onready var attack_second   = $bike_attacks/second_to_top/bike_attack
onready var attack_top      = $bike_attacks/top/bike_attack
onready var game_ui         = $player/game_UI
onready var i_e_anim        = $intro_end_anim/AnimationPlayer
onready var shake_timer     = $world_timers/shake_timer

var m_b_health = 18
var c_b_health = m_b_health
var atk_section  = 4
var intro_played = false
var boss_killed = false
var shake_amount = 3

func _physics_process(_delta):
	if c_b_health <= 0 and boss_killed == false:
		boss_killed = true
		on_boss_death()
		
	if shake_timer.time_left > 0:
		_shake()

func _ready():
	Globals.player.has_spawn_points = false

	$normal_ac.visible = false
	$lights.visible    = false
	$philips.visible   = false
	$dean_philips_boss.position = Vector2(1193.75, 214.5)
	$dean_philips_boss.scale.x = -1.5
	$dean_philips_boss.scale.y = 1.5
	$dean_philips_boss/aniamtions.play("idle")
	$err_node/error_zone.visible = false
	$player/Camera2D.queue_free()
	game_ui.on_no_checkpoints()
	game_ui.on_initialize_boss(m_b_health, "???")
	
	
	if intro_played == false:
		i_e_anim.play("intro")
		Globals.game_locked = true
		yield(i_e_anim, "animation_finished")
		_play_bike()



func _bike_attacks(number):
	$dean_philips_boss/engine.stop()
	while number > 0 and boss_killed == false:
		match atk_section:
			4:
				attack_floor.play ("ground_bar")
				yield(attack_floor, "animation_finished")
			3:
				attack_third.play ("ground_bar")
				yield(attack_third, "animation_finished")
			2:
				attack_second.play("ground_bar")
				yield(attack_second, "animation_finished")
			1:
				attack_top.play   ("ground_bar")
				yield(attack_top, "animation_finished")
		number -= 1
		shake_timer.set_wait_time(.5)
		shake_timer.start()
		$sounds/enemy_spawn_in.play()
	_play_bike()

func _on_damage_box_body_entered(body):
	if body == Globals.player:
		Globals.player.take_damage(1)

func _play_bike():
	if boss_killed == false:
		$dean_philips_boss/engine.play()
		dean_animations.play("idle_into_right")
		yield(dean_animations, "animation_finished")
		if intro_played == false:
			yield(get_tree().create_timer(2), "timeout")
			i_e_anim.play("transition_back")
			yield(i_e_anim, "animation_finished")
			intro_played = true
			Globals.game_locked = false
			activate_error_zone()
			
			
		game_ui.on_boss_healthbar_visible(true)
		dean_animations.play("idle_right")
		yield(dean_animations, "animation_finished")
		if boss_killed == false:
			dean_animations.play("move_left")
			shake_timer.set_wait_time(2)
			shake_timer.start()
			yield(dean_animations, "animation_finished")
			_bike_attacks(5)

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		c_b_health -= 1
		game_ui.on_boss_health_changed(c_b_health, c_b_health - 1)
		$sounds/metal_hit.play()
		_flash_damage(4,0.4)


func _on_top_body_entered(body):
	if body == Globals.player:
		atk_section = 1

func _on_second_top_body_entered(body):
	if body == Globals.player:
		atk_section = 2

func _on_third_top_body_entered(body):
	if body == Globals.player:
		atk_section = 3

func _on_floor_body_entered(body):
	if body == Globals.player:
		atk_section = 4

func _flash_damage(num_flashes: int = 0, flash_time: float = 0.03):
	shake_timer.set_wait_time(.3)
	shake_timer.start()

	var t = Timer.new()
	var s = Timer.new()
	s.set_one_shot(true)
	s.set_wait_time(flash_time)
	t.set_wait_time(.02)
	t.set_one_shot(true)
	self.add_child(t)
	
	if num_flashes <= 0:
		while s.wait_time > 0:
			t.start()
			yield(t, "timeout")
			$dean_philips_boss.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			t.start()
			yield(t, "timeout")
			$dean_philips_boss.set_modulate(Color(7.52, 7.52, 7.52, 1.0))
	else:
		for _i in range(num_flashes):
			t.start()
			yield(t, "timeout")
			$dean_philips_boss.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			t.start()
			yield(t, "timeout")
			$dean_philips_boss.set_modulate(Color(7.52, 7.52, 7.52, 1.0))
	$dean_philips_boss.set_modulate(Color.white)


func activate_error_zone():
	$lights.visible = true
	$err_node/error_zone.visible = true
	$err_node/error_zone/instructions.set_text("Destroy ???")
	$err_node/error_zone/error_text.set_text("Destroy ???")
	
	_show_error_zone()
	yield($err_node/error_zone/AnimationPlayer, "animation_finished")

func _show_error_zone():
	$sounds/error_sound.play()
	$sounds/siren.play()
	$sounds/music_attack.play()
	$sounds/music_idle.stop()
	shake_timer.wait_time = 2
	shake_timer.start()
	$err_node/error_zone/center_glitch.visible = true
	$err_node/error_zone/instructions.visible  = false
	$err_node/error_zone/instructions.rect_scale.y = 0.5
	
	$err_node/error_zone/error_text.visible = true
	yield(shake_timer, "timeout")
	$err_node/error_zone/error_text.visible = false

	$err_node/error_zone/center_glitch.visible = false
	$err_node/error_zone/instructions.visible  = true
	
	$err_node/error_zone/instructions_timeout.start()
	yield($err_node/error_zone/instructions_timeout, "timeout")
	$err_node/error_zone/AnimationPlayer.play("transitino_instructions")	

func deactive_error_zone():
	$sounds/siren.stop()
	$sounds/music_attack.stop()


func _shake():
	$Camera2D2.set_offset(Vector2( \
	rand_range(-1.0, 1.0) * shake_amount, \
	rand_range(-1.0, 1.0) * shake_amount  \
))

func on_boss_death():
	$dean_philips_boss/engine.stop()
	deactive_error_zone()
	_flash_damage(10,1)
	game_ui.on_boss_healthbar_visible(false)
	boss_killed = true
	dean_animations.play("defeated")
	yield(dean_animations, "animation_finished")
	$sounds/boss_explosion.play()
	dean_animations.stop()
	$dean_philips_boss/aniamtions.play("defeat")
	yield($dean_philips_boss/aniamtions, "animation_finished")

	$lights.visible = false
	$dean_philips_boss/flames_charge.visible = false
	$dean_philips_boss/CollisionShape2D.set_deferred("disabled", true)
	$dean_philips_boss/CollisionPolygon2D.set_deferred("disabled", true)
	$dean_philips_boss/Area2D.set_deferred("monitoring", false)
	$dean_philips_boss/lights.visible = false


	shake_timer.set_wait_time(.3)
	shake_amount = 10
	shake_timer.start()
	
	Globals.game_locked = true
	$player/sounds/SD4_footsteps.stop()
	$philips/AnimationPlayer.play("teleport_in")
	yield($philips/AnimationPlayer, "animation_finished")
	$philips/AnimationPlayer.play("philips_entrance")
	yield($philips/AnimationPlayer, "animation_finished")
	$philips/AnimationPlayer.play("fade_in_class")
	$sounds/static.play()
	yield($philips/AnimationPlayer, "animation_finished")
	$philips/philips/name.visible = false
	$sounds/static.stop()
	
	Globals.stop_highscore_timer()
	var game_ui = Globals.player.get_node("game_UI")
	var score = Globals.calculate_highscore(game_ui.get_cola_count(), Globals.get_highscore_timer(), game_ui.get_respawn_count())
	
	Globals.update_highscore_file_from_local()
	var previous_score = Globals.get_highscore_dictionary().academic_center
	
	if Globals.get_highscore_dictionary().academic_center < score:
		Globals.update_ac_score(score)
		
	game_ui.on_player_level_cleared(previous_score)
