extends Entity

var _ANIM: Dictionary = {
	IDLE   = "idle",
	REAR   = "rear_up",
	MOVE   = "move",
	CHARGE = "charge"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	_play_animation(_ANIM.MOVE)
	
	
func _play_animation(anim: String) -> void:
	if anim in _ANIM.values():
		$sprites/idle.visible    = false
		$sprites/move.visible    = false
		$sprites/rear_up.visible = false
		$flames_charge.visible   = false
		$flames_rear.visible     = false
		
		match anim:
			_ANIM.IDLE:
				$sprites/idle.visible = true
			_ANIM.REAR:
				$sprites/rear_up.visible = true
				$flames_rear.visible     = true
			_ANIM.MOVE:
				$sprites/move.visible = true
			_ANIM.CHARGE:
				$sprites/move.visible  = true
				$flames_charge.visible = true	
				
		$AnimationPlayer.play(anim)
		
