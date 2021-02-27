#-----------------------------------------------------------------------------#
# File Name:   door.gd
# Description: Door switching to different scenes
# Author:      Eric Cherubin
# Company:     Sidetrack
# Date:        November 12, 2020
#-----------------------------------------------------------------------------#


extends KinematicBody2D

export var ai_enabled:      bool  = true
# Movement speed
export var movement_speed:  float = 0.1875
# Seconds before drone shoots a 3x5 card
export var shoot_cooldown:  float = 3.0
# Seconds of movement before changing directions
export var turnaround_time: float = 1

export var health:       int   = 100
export var damage:       int   = 5
export var acceleration: float = 30

var player
var random_number = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
