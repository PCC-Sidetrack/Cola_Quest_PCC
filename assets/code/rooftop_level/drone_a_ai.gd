#-----------------------------------------------------------------------------#
# File Name:    drone_a_ai.gd                                                 #
# Description:  Directs the animation and ai for the dronea sprite            #
# Author:       Jeff Newell & Andrew Zedwick                                  #
# Company:      Sidetrack                                                     #
# Last Updated: December 2, 2020                                              #
#-----------------------------------------------------------------------------#
extends Entity

#-----------------------------------------------------------------------------#
#                                Constants                                    #
#-----------------------------------------------------------------------------#
# Holds a reference to the 3x5_projectile scene
const STUDY_CARD = preload("res://assets//sprite_scenes//rooftop_scenes//study_card_projectile.tscn")

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating if the sprite's ai is active
export var ai_enabled:      bool  = true

# Movement speed
export var movement_speed:  float = 1.5
# Seconds before drone shoots a 3x5 card
export var shoot_cooldown:  float = 3.0
# Seconds of movement before changing directions
export var turnaround_time: float = 0.5
# Acceleration applied to drone's movement
export var acceleration:    float = 20.0
# Knockback multiplier for drone
export var knockback:       float = 2.0

# Stores how much health the drone has
export var health:       int   = 2
# Amount of damage the drone deals
export var damage:       int   = 1


#-----------------------------------------------------------------------------#
#                            Private Variables                                #
#-----------------------------------------------------------------------------#
# Number of seconds since last movement update
var _movement_update_time: float = 0.0
# Number of seconds since last 3x5 card was shot
var _shoot_update_time:    float = 0.0
# Used to add a randomness to when the first shot occurs
var _rng:                  RandomNumberGenerator = RandomNumberGenerator.new()
# Used to check if the drone can currently shoot
var _shoot_enabled:        bool = true

#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready() -> void:
	# Give a random starting time to _shoot_update_time
	_shoot_update_time = _rng.randf_range(0.0, shoot_cooldown)
	
	var instructions = [
		duration (Vector2.UP, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions (instructions, true)
	initialize_enemy        (health, damage, movement_speed, acceleration)
	$healthbar.max_value = health
	set_knockback_multiplier(knockback)
	
	$AnimatedSprite.play("fly")
	$AudioStreamPlayer2D.play()


#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
func set_initial_direction_moving(direction: Vector2 = Vector2.DOWN) -> void:
	var instructions = [
		duration (direction, turnaround_time),
		end_point(global_position)
	]
	
	initialize_instructions (instructions, true)

#-----------------------------------------------------------------------------#
#                            Private Functions                                #
#-----------------------------------------------------------------------------#
# Built in function is called every physics frame
func _physics_process(delta: float) -> void:
	if ai_enabled:
		_shoot_update_time += delta
			
		# Handle the shooting timer of the drone
		if int(_shoot_update_time) >= shoot_cooldown:
			_shoot()
		
		move()

# Create a new instance of a study card projectile and shoot it out of the drone
func _shoot() -> void:
	if _shoot_enabled:
		# Save the position of the drone to the misc_loc vector in Globals. It will
		# be used by the study card.
		Globals.misc_loc = $StudyCardSpawn.global_position
		
		# Create, initialize, and add a new study card projectile to the drone
		var study_card = STUDY_CARD.instance()
		get_node("/root").add_child(study_card)
		study_card.global_position = Globals.misc_loc
		#$StudyCardSpawn.add_child(study_card)
		study_card.initialize()
		_shoot_update_time = 0.0
		
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
# Triggered when the drone dies
func _on_drone_a_death():
	# Used to wait a given amount of time before deleting the entity
	var timer: Timer = Timer.new()
	
	set_damage(0)
	$CollisionShape2D.set_deferred("disabled", true)
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	_shoot_enabled             = false
	timer.set_one_shot(true)
	add_child(timer)
	
	# Add an audio pitch fade out
	$sword_hit.play()
	$Tween.interpolate_property($AudioStreamPlayer2D, "pitch_scale", $AudioStreamPlayer2D.pitch_scale, 0.01, 50 * 0.04)
	$Tween.start()
	
	death_anim (50,  0.04)
	timer.start(50 * 0.04)
	yield(timer, "timeout")
	queue_free()

# On drone health changed
func _on_drone_a_health_changed(ammount):
	$healthbar.value   = get_current_health()
	$healthbar.visible = true
	if ammount < 0 and get_current_health():
		$sword_hit.play()
		flash_damaged(10)

	return get_tree().create_timer(1.5).connect("timeout", self, "_visible_timeout")

# On healthbar visibility timeout
func _visible_timeout():
	$healthbar.visible = false 


func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group(Globals.GROUP.PLAYER):
		body.take_damage(damage)
		_knockback_old(body)
		custom_knockback(self, 2.0, -global_position.direction_to(Globals.player_position))
