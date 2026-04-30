shader_type canvas_item;

uniform sampler2D texture_to_tile : repeat_enable, filter_nearest;
uniform vec2 tile_repeat = vec2(1.0, 1.0);

void fragment() {
    COLOR = texture(texture_to_tile, UV * tile_repeat);
}