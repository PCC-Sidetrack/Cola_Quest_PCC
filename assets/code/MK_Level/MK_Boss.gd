#-----------------------------------------------------------------------------#
# File Name:   	MK_Boss.gd                                                    #
# Description: 	Contols the MK_Orion enemy                                    #
# Author:      	Luke HAthcock                                                 #
# Company:    	Sidetrack                                                     #
# Last Updated:	March 20, 2021                                                #
#-----------------------------------------------------------------------------#

extends AI

signal fire_laser(true)

func _physics_process(delta):
	$MK_Boss_Laser1.is_casting = true
	$MK_Boss_Laser1.set_cast_to(Globals.player_position - $MK_Boss_Laser1.global_position)
	$MK_Boss_Laser2.is_casting = true
	$MK_Boss_Laser2.set_cast_to(Globals.player_position - $MK_Boss_Laser2.global_position)
