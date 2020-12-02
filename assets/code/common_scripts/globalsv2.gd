# Global constants for access by anything
extends Node

# Directions
const DIRECTION: Dictionary = {
	DOWN              = 1.0,
	CLOCKWISE         = 1.0,
	COUNTER_CLOCKWISE = -1.0,
	LEFT              = -1.0,
	RIGHT             = 1.0,
	UP                = -1.0,
}

# Groups
const GROUP: Dictionary = {
	COLLECTABLE  = "collectable",
	ENEMY        = "enemy",
	INTERACTABLE = "interactable",
	PLAYER       = "player",
	PROJECTILE   = "projectile",
	WORLD        = "world",
}

# Layers
const LAYER: Dictionary = {
	PLAYER       = 0,
	ENEMY        = 1,
	COLLECTABLE  = 2,
	WORLD        = 3,
	INTERACTABLE = 4,
	PROJECTILE   = 5,
	SPAWNPOINT   = 6,
}

# Orientation
const ORIENTATION: Dictionary = {
	FLOOR_NORMAL   = Vector2.UP,
	MAX_FALL_SPEED = 3200.0,
	TILE_SIZE      = 32.0,
}

# Initialize the random seed
func _ready() -> void:
	seed(OS.get_time().hour * (OS.get_time().minute + 1) * OS.get_time().second)

# Convert pixels to tiles
func pix2til(pixels: float) -> float:
	return pixels / ORIENTATION.TILE_SIZE

# Convert tiles to pixels
func til2pix(tiles: float) -> float:
	return tiles * ORIENTATION.TILE_SIZE
