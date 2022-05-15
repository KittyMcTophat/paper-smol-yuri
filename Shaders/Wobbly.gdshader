shader_type canvas_item;

uniform sampler2D h_offset_texture;
uniform sampler2D v_offset_texture;
uniform mediump vec2 h_scroll_speed = vec2(0.1, 0.1);
uniform mediump vec2 v_scroll_speed = vec2(-0.1, -0.1);
uniform mediump float max_pixel_offset : hint_range(0.0, 1000.0) = 30.0;
uniform mediump vec2 pixel_multiplier = vec2(1.0, 1.0);

void fragment(){
	COLOR = vec4(1.0, 0.0, 0.0, 0.0);
	
	mediump float h_offset = texture(h_offset_texture, UV + (TIME * h_scroll_speed)).r - 0.5;
	h_offset = (h_offset * 2.0) * max_pixel_offset * pixel_multiplier.x * SCREEN_PIXEL_SIZE.x;
	
	mediump float v_offset = texture(v_offset_texture, UV + (TIME * v_scroll_speed)).r - 0.5;
	v_offset = (v_offset * 2.0) * max_pixel_offset * pixel_multiplier.y * SCREEN_PIXEL_SIZE.y;
	
	COLOR = texture(SCREEN_TEXTURE, vec2(UV.x + h_offset, 1.0 - (UV.y + v_offset)));
}