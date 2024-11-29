shader_type canvas_item;

uniform float brightness: hint_range(-1.0, 1.0, 0.1) = 0.0;
uniform float contrast: hint_range(-10.0, 10.0, 0.01) = 1.0;
uniform float saturation: hint_range(-10.0, 10.0, 0.01) = 1.0;

mat4 brightness_matrix(float b){
	return mat4(
		vec4(1, 0, 0, 0),
		vec4(0, 1, 0, 0),
		vec4(0, 0, 1, 0),
		vec4(b, b, b, 1)
	);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	mat4 matrix = brightness_matrix(brightness);
	COLOR = color;
}
