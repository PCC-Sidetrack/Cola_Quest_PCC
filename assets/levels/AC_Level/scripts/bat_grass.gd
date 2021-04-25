#-----------------------------------------------------------------------------#
# File Name:   Bat/Spider.gd
# Description: Spider or Bat script
# Author:      Rightin Yamada
# Company:     Sidetrack
# Date:        April 9, 2021
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#                               Inheiritance                                  #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
onready var cola_can_instance  = preload("res://assets/levels/AC_Level/c_cola_temp.tscn")
onready var explosion_instance = preload("res://assets/levels/AC_Level/assets/sprites/explosion.tscn")
export var acceleration: float = 20.0
export var damage:       int   = 2
export var health:       int   = 2
export var jump_speed:   float = 1.0
export var speed:        float = 7.0
var attack_point
var engage_player = true

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	randomize()
#	initialize_enemy(health, damage, speed, acceleration, jump_speed, true, true)
	if self.is_in_group("bat"):    initialize_enemy(2, damage, rand_range(2,10), acceleration, jump_speed, false, true)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_smooth_movement        (true)
	set_knockback_multiplier   (1.0)
	set_auto_facing            (true)
	$spawn_in_effect.play()
	yield($spawn_in_effect, "animation_finished")
	$spawn_in_effect.visible = false
	$sounds/on_engage.play()

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(_delta: float) -> void:
	if engage_player == true:
		move_dynamically(global_position.direction_to(attack_point.position))
	$sounds/idle.pitch_scale = rand_range(1.2, 1.6)

#-----------------------------------------------------------------------------#
#                                Triggers                                     #
#-----------------------------------------------------------------------------#
func _on_spider_death():
	engage_player = false
	if self.is_in_group("bat"): $spawn_in_effect.play()
#	var cola_can = cola_can_instance.instance()
	var explosion = explosion_instance.instance()
#	cola_can.position = get_global_position()
	explosion.position = get_global_position()
#	get_tree().get_root().call_deferred("add_child",cola_can)
	if self.is_in_group("bat"):get_tree().get_root().call_deferred("add_child",explosion)
	if self.is_in_group("bat"):$explosion.play()
	
	$ground_collision.set_deferred("disabled", true)
	$hitbox.monitoring = false
	$sounds/on_death.play()
	yield($sounds/on_death, "finished")

	queue_free()

func _on_spider_health_changed(change):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if change < 0 and get_current_health():
		$sounds/on_damaged.play()
		_flash_damage(10)
	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

func _visible_timeout():
	$healthbar.visible = false

func _flash_damage(num_flashes: int = 0, flash_time: float = 0.03):
	var t = Timer.new()
	
	t.set_wait_time(flash_time)
	t.set_one_shot(true)
	self.add_child(t)
	
	if num_flashes <= 0:
		while get_invulnerability():
			t.start()
			yield(t, "timeout")
			set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			t.start()
			yield(t, "timeout")
			set_modulate(Color(7.52, 7.52, 7.52, 1.0))
	else:
		for _i in range(num_flashes):
			t.start()
			yield(t, "timeout")
			set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			t.start()
			yield(t, "timeout")
			set_modulate(Color(7.52, 7.52, 7.52, 1.0))
					
	set_modulate(Color.white)

func _on_detection_body_entered(body):
	if body == attack_point:
		$sounds/on_engage.play()

func _on_detection_body_exited(body):
	if body == attack_point:
		$sounds/on_disengage.play()


func _on_bat_death():
	_on_spider_death()


func _on_bat_health_changed(ammount):
	_on_spider_health_changed(ammount)

func attack_plane(node):
	attack_point = node
