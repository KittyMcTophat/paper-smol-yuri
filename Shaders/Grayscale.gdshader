shader_type canvas_item;

uniform float r_weight: hint_range(0.0, 1.0) = 1.0;
uniform float g_weight: hint_range(0.0, 1.0) = 1.0;
uniform float b_weight: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float total = 0.0;
	vec4 screenColor = texture(SCREEN_TEXTURE, SCREEN_UV);
	total += screenColor.r * r_weight;
	total += screenColor.g * g_weight;
	total += screenColor.b * b_weight;
	total /= (r_weight + g_weight + b_weight);
	COLOR = vec4(total, total, total, 1.0);
}