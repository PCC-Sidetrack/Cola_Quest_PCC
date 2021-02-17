#-----------------------------------------------------------------------------#
#                           Programmers Alert Code                            #
#-----------------------------------------------------------------------------#
# This is for letting other programmers know about upcoming changes in code
# It will (hopefully) help them know which functions are being changed


extends Node


# Used for keeping track of errors and warnings
var alert: Dictionary = {
	error   = {},
	warning = {},
}

# Gives warnings and erorrs to the programmer after the window has been closed
func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# Add push warnings and errors, and also print them to the console
		if alert.error.size() > 0:
			print("\n\nERORS: \n_____________")
			for error in alert.error:
				push_error(error)
				print("\n* ", error)
		
		if alert.warning.size() > 0:
			print("WARNINGS:\n_____________")
			for warning in alert.warning:
				push_warning(warning)
				print("\n* ", warning)
		
		# print an extra couple of lines to make the console easier to read
		print("\n\n\n")
		get_tree().quit()
		


# Add error to be reported
func add_error(message: String, code: int = 0) -> void:
	if not alert.error.has(message):
		alert.error[message] = code

# Add warning to be reported
func add_warning(message: String, code: int = 0) -> void:
	if not alert.warning.has(message):
		alert.warning[message] = code
