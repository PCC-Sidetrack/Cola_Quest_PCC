#-----------------------------------------------------------------------------#
# File Name:   MK_Boss_Laser.gd
# Description: Laser for MK_Boss
# Author:      Luke Hathcock
# Company:     Sidetrack
# Date:        March 24, 2021
#-----------------------------------------------------------------------------#

extends RayCast2D

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
var is_casting := false setget set_is_casting
var cast_point := cast_to
var angleX       = cast_point.x - position.x
var angleY       = -1 * cast_point.y - position.x
var hyp_len      = sqrt((angleX * angleX) + (angleY * angleY))
var deg_angle    = asin(angleY /hyp_len)
#-----------------------------------------------------------------------------#
#                                Constructor                                  #
#-----------------------------------------------------------------------------#
func _ready():
	set_physics_process(false)
	$Line2D.points[1]         = Vector2.ZERO
	$Emit_Particle.emitting   = false
	$Impact_Particle.emitting = false
	$Light2D.enabled          = false
#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
func _physics_process(delta):
	force_raycast_update()
	
	$Impact_Particle.emitting = is_colliding()
	
	if is_colliding():
		cast_point                       = to_local(get_collision_point())
		$Impact_Particle.global_rotation = get_collision_normal().angle()
		$Impact_Particle.position        = cast_point
		$Light2D.enabled                 = true
		
	$Line2D.points[1] = cast_point
	$Light2D.position = to_local(get_collision_point())

func set_is_casting(cast: bool):
	
	$Emit_Particle.emitting = cast
	
	if cast:
		shoot()
	else:
		stop()
		$Impact_Particle.emitting = false
		$Light2D.enabled          = false
		
	set_physics_process(cast)
	
func shoot():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 10, 0.2)
	$Tween.start()
	
func stop():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 10, 0, 0.1)
	$Tween.start()
#-----------------------------------------------------------------------------#
#                            Trigger Functions                                #
#-----------------------------------------------------------------------------#
#func _unhandled_input(event: InputEvent):
#	if event is InputEventMouseButton:
#		self.is_casting = event.pressed

