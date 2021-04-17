extends Control

signal body_left(body)

var enemies_remaining
var error_text
var error_position
var shake_timer


func error_zone_init(enemy_remain, err_text, shake_node):
	shake_timer       = shake_node
	enemies_remaining = enemy_remain
	error_text        = err_text
	
func _on_enemies_left_body_exited(body):
	emit_signal("body_left", body)

func activate_error_zone():
	$bugs_left.visible = true
	$instructions.set_text("Destroy " + str(enemies_remaining) + " bugs!")
	$error_text.set_text(error_text)
	
	# Tween the camera to the new position
#	camera_tween.interpolate_property(camera, "limit_left", Globals.player.position.x, 2501, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
#	camera_tween.interpolate_property(camera, "limit_right", Globals.player.position.x, 3281, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
#	camera_tween.start()
#	yield(camera_tween, "tween_all_completed")
	
	_show_error_zone()
	yield($AnimationPlayer, "animation_finished")

func _show_error_zone():
	$sounds/error_sound.play()
	$sounds/siren.play()
	$sounds/music_attack.play()
	$sounds/music_idle.stop()
	shake_timer.wait_time         = 2
	shake_timer.start()
	self.visible     = true
	$center_glitch.visible = true
	$instructions.visible  = false
	$instructions.rect_scale.y = 0.5
	$bugs_left.visible  = false
	
	$error_text.visible = true
	yield(shake_timer, "timeout")
	$error_text.visible = false

	$center_glitch.visible = false
	$instructions.visible  = true
	
	$instructions_timeout.start()
	yield($instructions_timeout, "timeout")
	$AnimationPlayer.play("transitino_instructions")	
	yield($AnimationPlayer, "animation_finished")
	$bugs_left.visible = true

func deactive_error_zone():
	$sounds/siren.stop()
	$sounds/music_attack.stop()
