#-----------------------------------------------------------------------------#
# File Name:    shark.gd                                                      #
# Description:  Directs the animation and ai for the shark sprite             #
# Author:       Sephrael Lumbres                                              #
# Company:      Cola Quest                                                    #
# Last Updated: March 31, 2021                                                #
#-----------------------------------------------------------------------------#

extends Entity

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:         bool  = true
# Movement speed
export var movement_speed:     float = 4
# Seconds of movement before changing directions
export var turnaround_time:    float = 2
# Start facing right?
export var start_moving_right: bool  = true
export var health:             int   = 2
export var damage:             int   = 1
export var accelertion:        float = 20.0
export var knockback:          float = 2

var is_player_in_range: bool = false
var direction = Globals.DIRECTION.NONE
var check_health = health - 1

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	
	# Holds the ai instructions
	var instructions: Array
	
	# Set the ai instructions based on which initial direction the bird is moving
	instructions = [
		duration (Vector2.RIGHT if start_moving_right else Vector2.LEFT, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions    (instructions, true)
	initialize_enemy           (health, damage, movement_speed, accelertion)
	set_knockback_multiplier   (knockback)
	set_sprite_facing_direction(Globals.DIRECTION.RIGHT)
	set_auto_facing            (true)

	$AnimatedSprite.play("swim")
	$healthbar.max_value = health


#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(_delta: float) -> void:
	if ai_enabled and not is_player_in_range:
		move()
		rotation = 0.0
		$AnimatedSprite.flip_v = false
		#$AnimatedSprite.flip_h = false
	
	if is_player_in_range:
		ai_enabled = false
		move_dynamically(Globals.player_position - global_position)
		#rotation = lerp_angle(rotation, (Globals.player_position - global_position).angle(), 0.05)
		if (rotation > -1.5 and rotation < 1.5) or (rotation < 1.5 and rotation > -1.5):
			#rotation = (Globals.player_position - global_position).angle()
			rotation = lerp_angle(rotation, (global_position - Globals.player_position).angle(), 0.05)
			$AnimatedSprite.flip_v = false
			$AnimatedSprite.flip_h = true
			direction = Globals.DIRECTION.LEFT
		elif rotation < -1.5 or rotation > 1.5:
			#rotation = (Globals.player_position - global_position).angle()
			#rotation = (global_position - Globals.player_position).angle()
			#rotation = lerp_angle(rotation, (Globals.player_position - global_position).angle(), 0.05)
			rotation = lerp_angle(rotation, (global_position - Globals.player_position).angle(), 0.05)
			$AnimatedSprite.flip_v = true
			$AnimatedSprite.flip_h = true
			direction = Globals.DIRECTION.RIGHT
	else:
		ai_enabled = true

#func spin_sprite():
#	var timer: Timer = Timer.new()
#	for i in 100:
#		timer.set_one_shot(true)
#		add_child(timer)
#		timer.start(0.01)
#		yield(timer, "timeout")
#		$AnimatedSprite.rotation_degrees = $AnimatedSprite.rotation_degrees + 30
#		i += 1

#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered whenever the entity dies	
func _on_shark_death() -> void:
	set_obeys_gravity(true)
	#spin_sprite()
	
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	$follow_range.set_collision_mask(0)
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	set_collision_mask(0)
	set_collision_layer(0)
	timer.set_one_shot(true)
	add_child(timer)
	
	$sword_hit.play()
	death_anim (20, 0.05)
	timer.start(20 * 0.05)
	yield(timer, "timeout")
	queue_free()

func _on_follow_range_body_entered(body: Node) -> void:
	movement_speed = 1
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		is_player_in_range = true

func _on_follow_range_body_exited(body: Node) -> void:
	if(body.is_in_group(Globals.GROUP.PLAYER)):
		is_player_in_range = false

	if direction == Globals.DIRECTION.LEFT:
			set_direction_facing(Globals.DIRECTION.LEFT)
			$AnimatedSprite.flip_h = true
	elif direction == Globals.DIRECTION.RIGHT:
			set_direction_facing(Globals.DIRECTION.RIGHT)
			$AnimatedSprite.flip_h = false

func _on_shark_collision(body) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body._knockback_old(self)
		deal_damage(body)

func _on_shark_health_changed(amount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true

	if check_health:
		flash_damaged(10)
		check_health -= amount

	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		_knockback_old(body)
		#custom_knockback(self, 6.0, -global_position.direction_to(Globals.player_position))
		body._knockback_old(self)
