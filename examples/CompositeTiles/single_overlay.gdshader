shader_type canvas_item;

uniform sampler2D overlay_texture: repeat_enable, filter_nearest;
uniform sampler2D mask_texture: repeat_enable, filter_nearest;
uniform float scale_overlay=1;
uniform bool enabled=true;
varying vec2 world_position;


void vertex(){
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	// only apply overlay_tex on the fully red parts of the original tiles
	// sample the overlay_tex using worldPos
	vec4 mask = texture(mask_texture, UV);
	vec2 scale = world_position / max(scale_overlay, 0.001);
	vec4 overlay_color = texture(overlay_texture, scale);
	//combine original color and overlay color together
	float a = COLOR.a;
	// Switch case-like selection using the blend_mode integer
	COLOR = mix(COLOR,overlay_color, mask);
	COLOR.a=a*float(enabled);
}