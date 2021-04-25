#-----------------------------------------------------------------------------#
# File Name:   	globals.gd                                                    #
# Description: 	Holds globally accessable variables/methods                   #
# Author:      	Jeff Newell & Andrew Zedwick                                  #
# Company:    	Sidetrack                                                     #
# Last Updated:	December 4th, 2020                                            #
#-----------------------------------------------------------------------------#
extends Node


#-----------------------------------------------------------------------------#
#                               Public Constants                              #
#-----------------------------------------------------------------------------#

# Directions
const DIRECTION: Dictionary = {
	NONE              = 0.0,
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
	SPAWNPOINT   = "spawnpoint",
	ENTITY       = "entity"
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
	MAX_FALL_SPEED = 3000,
	TILE_SIZE      = 32.0,
}

# Score weights for highscores
var HIGHSCORE_WEIGHTS: Dictionary = {
	COLA   = 20.0,
	SECOND = -1/3, # 30 seconds subtracts 10 points
	DEATH  = -50
}


#-----------------------------------------------------------------------------#
#                               Public Variables                              #
#-----------------------------------------------------------------------------#
# The position of the player
# This is here only to aid in locating the player, considering the fact that many things will need the players location and that the player will probably not be in the same tree in every level
var player_position: Vector2 = Vector2.ZERO

# Holds reference to the player node itself so it can be easily referenced
# This variable is set by the player.gd ready() function
var player:          Entity = null

# Whether or not the player controls are currently locked (used for cutscenes)
var game_locked:     bool    = false

# Holds a vector for miscellanious use (especially when initializing projectiles)
var misc_loc:        Vector2 = Vector2(0, 0)


#-----------------------------------------------------------------------------#
#                              Private Variables                              #
#-----------------------------------------------------------------------------#
# Default highscore dictionary
var _default_highscores: Dictionary = {
	"rooftop"         : 0.0,
	"sports_center"   : 0.0,
	"makenzie"        : 0.0,
	"crown_centre"    : 0.0,
	"academic_center" : 0.0
}

# Highscore dictionary
var _highscores: Dictionary = {
	"rooftop"         : 0.0,
	"sports_center"   : 0.0,
	"makenzie"        : 0.0,
	"crown_centre"    : 0.0,
	"academic_center" : 0.0
}

var _highscore_path: String = "highscores.json"

# Keeps track of the time spent in a level
var _highscore_time: float = 0.0

# Determins if the highscore time should be tracked currenlty
var _tracking_highscore: bool = false

#-----------------------------------------------------------------------------#
#                           Built-In Virtual Methods                          #
#-----------------------------------------------------------------------------#
# Initialize the random seed
func _ready() -> void:
	# Create the highscore file if it doesn't exist and update the local highscore
	# to match the saved one
	_create_highscore_file()
	update_local_highscore_from_file()
	
	seed(OS.get_time().hour * (OS.get_time().minute + 1) * OS.get_time().second)


# physics process
func _physics_process(delta) -> void:
	# Keeping track of timer
	if _tracking_highscore:
		_highscore_time += delta

#-----------------------------------------------------------------------------#
#                                Public Methods                               #
#-----------------------------------------------------------------------------#
# Convert pixels to tiles
func pix2til(pixels: float) -> float:
	return pixels / ORIENTATION.TILE_SIZE

# Convert tiles to pixels
func til2pix(tiles: float) -> float:
	return tiles * ORIENTATION.TILE_SIZE
	
# Returns the highscore dictionary
func get_highscore_dictionary() -> Dictionary:
	_highscores = _get_highscores()
	return _highscores
	
# Forces a local variable update to the current highscore dictionary
func update_local_highscore_from_file() -> void:
	_highscores = _get_highscores()
	
# Saves whatever is in the local highscore dicionary to the highscore file
func update_highscore_file_from_local() -> void:
	var file: File = File.new()
	
	# If the file doesn't exist, create it
	if not file.file_exists(_highscore_path):
		_create_highscore_file()
		
	file.open(_highscore_path, File.WRITE)
	file.store_line(to_json(_highscores))
	
	file.close()
	
# Calculates a highscore based on the parameters given
func calculate_highscore(colas: int, seconds_taken: float, deaths: int) -> float:
	var highscore: float = (colas * HIGHSCORE_WEIGHTS.COLA) + \
			(seconds_taken * HIGHSCORE_WEIGHTS.SECOND) + (deaths * HIGHSCORE_WEIGHTS.DEATH)
	return highscore if highscore >= 0.0 else 0.0
	
# Updates the highscore for the rooftop level
func update_rooftop_score(score: float) -> void:
	update_local_highscore_from_file()
	_highscores.rooftop = score
	update_highscore_file_from_local()
	
# Updates the highscore for the sc level
func update_sc_score(score: float) -> void:
	update_local_highscore_from_file()
	_highscores.sports_center = score
	update_highscore_file_from_local()
	
# Updates the highscore for the mk level
func update_mk_score(score: float) -> void:
	update_local_highscore_from_file()
	_highscores.makenzie = score
	update_highscore_file_from_local()
	
# Updates the highscore for the cc level
func update_cc_score(score: float) -> void:
	update_local_highscore_from_file()
	_highscores.crown_centre = score
	update_highscore_file_from_local()

# Updates the highscore for the ac level
func update_ac_score(score: float) -> void:
	update_local_highscore_from_file()
	_highscores.academic_center = score
	update_highscore_file_from_local()
	
# Starts the highscore timer
func start_highscore_timer() -> void:
	_tracking_highscore = true
	
# Stops the highscore timer
func stop_highscore_timer() -> void:
	_tracking_highscore = false

# Resets the highscore timer
func reset_highscore_timer() -> void:
	_highscore_time = 0.0
	
# Gets the highscore timer
func get_highscore_timer() -> float:
	return _highscore_time
	
#-----------------------------------------------------------------------------#
#                               Private Methods                               #
#-----------------------------------------------------------------------------#
# Gets the highscore file as a dictionary
func _get_highscores() -> Dictionary:
	var file: File = File.new()
	var text: String
	# Holds the highscore file data in a Varient form (theoretically a dictionary
	var data: Dictionary = _default_highscores
	
	if not file.file_exists(_highscore_path):
		_create_highscore_file()
	
	
	file.open(_highscore_path, file.READ)
	text = file.get_as_text()
	
	# If the file is not a valid json file, then delete and reset it
	var data2 = parse_json(text)
	
	# If the type returned by parse_json is not a Dictionary, then delete it and reset it
	if not typeof(data2) == TYPE_DICTIONARY:
		ProgramAlerts.add_error("The highscore file was not properly converted to a Dictionary. Deleting it and resetting it.")
		_delete_highscore_file()
		_create_highscore_file()
	else:
		data = data2
	
	file.close()
	
	return data

# Creates a highscore file if it doesn't already exist
func _create_highscore_file() -> bool:
	var file_exists: bool = false
	
	var file: File = File.new()
	
	if not file.file_exists(_highscore_path):
		file.open(_highscore_path, File.WRITE)
		file.store_line(to_json(_default_highscores))
	else:
		file_exists = true
		
	file.close()
	
	return file_exists

# Deletes the highscore file if it exists
func _delete_highscore_file():
	var dir = Directory.new()

	if dir.file_exists(_highscore_path):
		dir.remove(_highscore_path)
	
