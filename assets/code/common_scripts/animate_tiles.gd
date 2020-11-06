#-----------------------------------------------------------------------------#
# File Name:   	animate_tiles.gd                                              #
# Description: 	Contains functions used to animate any tilesheet              #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#

class_name Animate_Tiles
extends    TileMap

#-----------------------------------------------------------------------------#
#                           Exported Variables                                #
#-----------------------------------------------------------------------------#
# Boolean indicating in aniation should take place
export var animate: bool = true

#-----------------------------------------------------------------------------#
#                                Variables                                    #
#-----------------------------------------------------------------------------#
# Current _time of animation
var _time: 		int  = 0
# Max number of saved _times before _time resets
var _max_time: int  = 1000

#-----------------------------------------------------------------------------#
#                            Built-In Functions                               #
#-----------------------------------------------------------------------------#
#  Process func that handles animations of tiles in the collidable tilesheet
func _process(delta: float) -> void:
	# Only perform animation processes if animation is set to occur
	if animate:
		# Animate all choosen tiles
		animate_tiles()
		
		# Increase the current _time for use in animation timing
		if _time >= _max_time:
			_time = 0
		else:
			_time += 1
			
#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Function that animates all tiles. Overwrite in code that extends this file
func animate_tiles() -> void:
	pass

# Animates the fan tiles
func animate_tile(tile_id: int, tile_span: int, x_tile_iter: int, rate: int) -> void:
	# Check that the rate of animation given is not above the max saved _times
	if rate > _max_time:
		rate = _max_time
		
	# When required, change the image in the animation
	if _time % rate == 0:
		for cell in get_used_cells_by_id(tile_id):
			# Holds the coordinate of the current cell in the loop
			var coord: Vector2 = get_cell_autotile_coord(cell.x, cell.y)		
			
			if int(coord.x + 1) + x_tile_iter > tile_span:
				set_cell(cell.x, cell.y, tile_id, false, false, false,
						Vector2(coord.x - tile_span + x_tile_iter, coord.y))
			else:
				set_cell(cell.x, cell.y, tile_id, false, false, false,
						Vector2(coord.x + x_tile_iter, coord.y))
