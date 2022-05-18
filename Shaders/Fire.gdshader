shader_type canvas_item;

uniform sampler2D tex_1;
uniform sampler2D tex_2;
uniform sampler2D gradient;

uniform vec2 scroll_1 = vec2(0.04, 0.4);
uniform vec2 scroll_2 = vec2(0.2, 0.0);

uniform float v_subtract_mult : hint_range(-10.0, 10.0) = 0.4;
uniform float edge_subtract_mult : hint_range(-10.0, 10.0) = 0.6;

void fragment() {
	float energy = texture(tex_1, UV + scroll_1 * TIME).r + texture(tex_2, UV + scroll_2 * TIME).r;
	energy /= 2.0;
	energy -= (1.0 - UV.y) * v_subtract_mult;
	energy -= abs(0.5 - UV.x) * edge_subtract_mult;
	COLOR = texture(gradient, vec2(energy));
}