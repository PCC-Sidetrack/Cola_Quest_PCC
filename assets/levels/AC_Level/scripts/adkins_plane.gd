extends KinematicBody2D



export (int) var speed = 600

var         can_fire     = true
var         fire_rate    = .1
var         shake_amount = 5
var         bullet       = preload("res://assets/levels/AC_Level/assets/sprites/Bullet.tscn")
export  var bullet_speed = 800
var plane_on = false

onready var shake_timer        = get_owner().get_node("world_timers/shake_timer")
	
func _shake():
	get_owner().get_node("static_plane_cam").set_offset(Vector2( \
	rand_range(-1.0, 1.0) * shake_amount, \
	rand_range(-1.0, 1.0) * shake_amount  \
))

func _physics_process(_delta):
	if plane_on:
		var movement_direction := Vector2.ZERO

		if Input.is_action_pressed("move_up"):
			movement_direction.y = -1
		if Input.is_action_pressed("move_down"):
			movement_direction.y = 1
		if Input.is_action_pressed("move_left"):
			movement_direction.x = -1
		if Input.is_action_pressed("move_right"):
			movement_direction.x = 1

		movement_direction = movement_direction.normalized()
		move_and_slide(movement_direction * speed)
	if plane_on:
		if shake_timer.time_left > 0:
			_shake()

		if Input.is_action_pressed("melee_attack") and can_fire:
			shake_timer.wait_time         = .1
			shake_timer.start()
			get_parent().get_node("sounds/cannon_fire").play()
			var bullet_instance = bullet.instance()
			bullet_instance.position = $fire_point.get_global_position()
			bullet_instance.rotation_degrees = rotation_degrees
			bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
			get_tree().get_root().add_child(bullet_instance)
			get_parent().get_node("sounds/cannon_fire").play()
			can_fire = false
			return get_tree().create_timer(fire_rate).connect("timeout", self, "_can_fire")

func _can_fire():
	can_fire = true 

func enable_plane():
	plane_on = true

func disable_plane():
	plane_on = false
