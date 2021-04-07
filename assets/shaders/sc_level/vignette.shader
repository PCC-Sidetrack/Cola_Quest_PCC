shader_type canvas_item;
uniform vec2 player_position;
uniform vec4 color : hint_color = vec4(0.305, 0.298, 0.341,1);

uniform float MULTIPLIER = 0.56;
uniform float SCALE = 0.5;
uniform float SOFTNESS = 0.45;

void fragment(){
	float val = distance(vec2(UV.x , UV.y * MULTIPLIER), vec2(player_position.x , player_position.y * MULTIPLIER));
	val = val / SCALE;
	float vignette = smoothstep(0.2, SOFTNESS, val);
	COLOR = vec4(color.rgb , vignette );
}