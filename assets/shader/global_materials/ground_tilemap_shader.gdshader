shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform bool enabled;

void fragment() {
	if(enabled) {
		COLOR = vec4(0.5 + 0.5 * sin(0.2 * TIME), 0.5 + 0.5 * sin(0.35 * TIME), 0.5 + 0.5 * sin(0.6 * TIME), texture(TEXTURE, UV).a);
	}
	else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
