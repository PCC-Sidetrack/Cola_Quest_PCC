#-----------------------------------------------------------------------------#
# File Name:   	lvl1_animate_col_tiles.gd                                     #
# Description: 	Animates tiles for the rooftop level collidable tiles         #
# Author:      	Andrew Zedwick                                                #
# Company:    	Sidetrack                                                     #
# Last Updated:	November 5th, 2020                                            #
#-----------------------------------------------------------------------------#
extends Animate_Tiles

#-----------------------------------------------------------------------------#
#                             Public Functions                                #
#-----------------------------------------------------------------------------#
# Overwrite the animate_tiles() function to animate specific collidable tiles
func animate_tiles():
	animate_tile(13, 7,  1, 1) # Animate fan tiles - code 13
	animate_tile(15, 13, 1, 3) # Animate concrete_c tiles - code 15
	animate_tile(17, 8,  2, 3) # Animate medium fan tiles - code 17
	animate_tile(19, 2,  1, 2) # Animate fan tiles - code 19
	animate_tile(20, 2,  1, 2) # Animate fan tiles - code 20
	animate_tile(21, 2,  1, 2) # Animate fan tiles - code 21
	animate_tile(22, 2,  1, 2) # Animate fan tiles - code 22
