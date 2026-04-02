class_name PonyDynamicSprite

extends Sprite2D

var frame_width = 64
var frame_height = 64

func assign_sprite(sprite_tex):
	self.texture = sprite_tex

func set_num_colors(val : int):
	if material is ShaderMaterial:
		material.set_shader_parameter("active_colors", val)

func set_in_color(id : int, color):
	if material is ShaderMaterial:
		if color is Color:
			color = Vector4(color.r, color.g, color.b, color.a)
		if color is Vector3:
			color = Vector4(color.x, color.y, color.z, 1.0)
		var in_color: Array = material.get_shader_parameter("in_color")
		if id >= 0 and id < in_color.size():
			in_color[id] = color
		material.set_shader_parameter("in_color", in_color)

# Color may be Vec4, Color, or even Vec3 (a = 1.0 by default)
func set_out_color(id : int, color):
	if material is ShaderMaterial:
		if color is Color:
			color = Vector4(color.r, color.g, color.b, color.a)
		if color is Vector3:
			color = Vector4(color.x, color.y, color.z, 1.0)
		var out_color: Array = material.get_shader_parameter("out_color")
		if id >= 0 and id < out_color.size():
			out_color[id] = color
		material.set_shader_parameter("out_color", out_color)

func get_num_colors() -> int:
	if material is ShaderMaterial:
		return material.get_shader_parameter("active_colors")
	return 1

func get_colors() -> Array[Color]:
	if material is ShaderMaterial:
		var out_arr : Array[Color] = []
		var out_color = material.get_shader_parameter("out_color")
		for i in range(0, get_num_colors()):
			var col_vec : Vector4 = out_color[i]
			out_arr.append(Color(col_vec.x, col_vec.y, col_vec.z, col_vec.w))
		return out_arr
	return []

func get_html_colors() -> Array[String]:
	var body_colors : Array[String] = []
	for c in get_colors():
		body_colors.append(c.to_html(true))
	return body_colors

# On your Sprite2D's parent or the node being animated
func set_atlas_region(frame_index: int) -> void:
	var atlas := texture as AtlasTexture
	if atlas:  # guard in case another animation has swapped to a non-Atlas texture
		atlas.region = Rect2(frame_index * frame_width, 0, frame_width, frame_height)

func make_atlas_unique():
	var atlas := texture as AtlasTexture
	if atlas:
		texture = atlas.duplicate()
