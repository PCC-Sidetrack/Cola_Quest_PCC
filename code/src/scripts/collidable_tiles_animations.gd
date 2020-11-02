extends TileMap

# Boolean indicating in aniation should take place
var animate: 	bool = true
# Current frame of animation
var frame: 		int  = 0
# Max number of saved frames before frame resets
var max_frames: int  = 1000

# Animates certain tiles in the collidable tilesheet for level_1
func _physics_process(delta: float) -> void:
	# Only perform animation processes if animation is set to occur
	if animate:
		# Animate all choosen tiles
		animate_tile(12, 7,  1, 1) # Animate fan tiles - code 12
		animate_tile(14, 14, 1, 3) # Animate concrete_a tiles - code 14
		animate_tile(15, 14, 1, 3) # Animate concrete_b tiles - code 15
		animate_tile(16, 8,  2, 5) # Animate medium fan tiles - code 16
		
		# Increase the current frame for use in animation timing
		if frame >= max_frames:
			frame = 0
		else:
			frame += 1
	
	
# Animates the fan tiles
func animate_tile(tile_id: int, tile_span: int, x_tile_iter: int, rate: int) -> void:
	# Check that the rate of animation given is not above the maximum saved frames
	if rate > max_frames:
		rate = max_frames
		
	# When required, indicated by the rate variable, change the image in the animation
	if frame % rate == 0:
		for cell in get_used_cells_by_id(tile_id):
			# Holds the coordinate of the current cell in the loop
			var coord: Vector2 = get_cell_autotile_coord(cell.x, cell.y)		
			
			if int(coord.x + 1) + x_tile_iter > tile_span:
				set_cell(cell.x, cell.y, tile_id, false, false, false,
						Vector2(coord.x - tile_span + x_tile_iter, coord.y))
			else:
				set_cell(cell.x, cell.y, tile_id, false, false, false,
						Vector2(coord.x + x_tile_iter, coord.y))
