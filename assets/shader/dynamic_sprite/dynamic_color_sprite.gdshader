shader_type canvas_item;

uniform int active_colors : hint_range(1, 8) = 2;
// Supports up to 8 Colors max for fastest processing.
// Use a custom shader if more are REALLY needed, but like.. don't?
uniform vec4 in_color[8];
uniform vec4 out_color[8];

void fragment() {
	for(int i = 0; i < active_colors; i++) {
		if(COLOR == in_color[i]) {
			COLOR = out_color[i];
			break;
		}
	}
}
