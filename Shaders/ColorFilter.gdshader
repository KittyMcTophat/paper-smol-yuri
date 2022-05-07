shader_type canvas_item;

uniform float r_mult: hint_range(0.0, 1.0) = 1.0;
uniform float g_mult: hint_range(0.0, 1.0) = 1.0;
uniform float b_mult: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 screenColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	screenColor.r *= r_mult;
	screenColor.g *= g_mult;
	screenColor.b *= b_mult;
	COLOR = screenColor;
}