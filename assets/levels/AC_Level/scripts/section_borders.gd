extends StaticBody2D

func enable():
	$left.set_deferred("disabled", false)
	$right.set_deferred("disabled", false)

func disable():
	$left.set_deferred("disabled", true)
	$right.set_deferred("disabled", true)
