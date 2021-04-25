extends Sprite

func _ready():
	material.set_shader_param("nb_frames",Vector2(hframes, vframes))


func _process(delta):
	material.set_shader_param("frame_coords",frame_coords)
	material.set_shader_param("velocity",get_parent().velocity)
