shader_type canvas_item;

uniform sampler2D h_offset_texture;
uniform sampler2D v_offset_texture;
uniform vec2 h_scroll_speed = vec2(0.1, 0.1);
uniform vec2 v_scroll_speed = vec2(-0.1, -0.1);
uniform float max_pixel_offset : hint_range(0.0, 1000.0) = 30.0;
uniform float pixel_multiplier = 1.0;

void fragment(){
	COLOR = vec4(1.0, 0.0, 0.0, 0.0);
	
	float h_offset = texture(h_offset_texture, UV + (TIME * h_scroll_speed)).r - 0.5;
	h_offset = (h_offset * 2.0) * max_pixel_offset * pixel_multiplier * SCREEN_PIXEL_SIZE.x;
	float v_offset = texture(v_offset_texture, UV + (TIME * h_scroll_speed)).r - 0.5;
	v_offset = (v_offset * 2.0) * max_pixel_offset * pixel_multiplier * SCREEN_PIXEL_SIZE.y;
	
	COLOR = texture(SCREEN_TEXTURE, vec2(UV.x + h_offset, 1.0 - (UV.y + v_offset)));
}