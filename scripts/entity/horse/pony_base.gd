# Individual Ponies with animations should extend this class.
class_name PonyBase

extends Node2D

@onready var back_bounce: PonyDynamicSprite = $BackBounce
@onready var back_stationary: PonyDynamicSprite = $BackStationary
@onready var back_legs: PonyDynamicSprite = $BackLegs
@onready var tail: PonyDynamicSprite = $Tail
@onready var base: PonyDynamicSprite = $Base
@onready var head: PonyDynamicSprite = $Head
@onready var eye_base: Sprite2D = $EyeBase
@onready var eye_color: PonyDynamicSprite = $EyeColor
@onready var front_legs: PonyDynamicSprite = $FrontLegs
@onready var butt_mark: Sprite2D = $ButtMark
@onready var wings: Sprite2D = $Wings
@onready var stationary: PonyDynamicSprite = $Stationary
@onready var horn: PonyDynamicSprite = $Horn
@onready var front_stationary: PonyDynamicSprite = $FrontStationary
@onready var front_bounce: PonyDynamicSprite = $FrontBounce

@onready var animation_player: PonyAnimationController = $AnimationPlayer

var loaded_mane : String = "twilight_sparkle"
var loaded_tail : String = "twilight_sparkle"
var pony_name : String = "Twilight Sparkle"

@onready var pony_importer_exporter: PonyImporterExporter = $PonyImporterExporter

var pone_base_colors : Array[Vector4] = [
	Vector4(1.0, 1.0, 1.0, 1.0),
	Vector4(224. / 255., 224. / 255., 224. / 255., 1.0),
	Vector4(180. / 255., 180. / 255., 180. / 255., 1.0),
	Vector4(154. / 255., 154. / 255., 154. / 255., 1.0)
]

func _ready() -> void:
	reset_base_colors()

func reset_base_colors():
	set_base_num_colors(4)
	eye_color.set_num_colors(1)
	eye_color.set_in_color(0, Color.WHITE)
	eye_color.set_out_color(0, Color.WHITE)
	for i in range(0, 4, 1):
		base.set_in_color(i, pone_base_colors[i])
		base.set_out_color(i, pone_base_colors[i])
		head.set_in_color(i, pone_base_colors[i])
		head.set_out_color(i, pone_base_colors[i])
		front_legs.set_in_color(i, pone_base_colors[i])
		front_legs.set_out_color(i, pone_base_colors[i])
		back_legs.set_in_color(i, pone_base_colors[i])
		back_legs.set_out_color(i, pone_base_colors[i])
		horn.set_in_color(i, pone_base_colors[i])
		horn.set_out_color(i, pone_base_colors[i])

func set_base_num_colors(val : int):
	base.set_num_colors(val)
	head.set_num_colors(val)
	front_legs.set_num_colors(val)
	back_legs.set_num_colors(val)
	horn.set_num_colors(val)

func set_num_eye_colors(val : int):
	eye_color.set_num_colors(val)

func recolor_eye(color_id : int, new_color : Vector4):
	eye_color.set_out_color(color_id, new_color)

func recolor_base(color_id : int, new_color : Vector4):
	base.set_out_color(color_id, new_color)
	head.set_out_color(color_id, new_color)
	front_legs.set_out_color(color_id, new_color)
	back_legs.set_out_color(color_id, new_color)
	horn.set_out_color(color_id, new_color)

func get_mane_components() -> Array[PonyDynamicSprite]:
	return [back_bounce, back_stationary, stationary, front_stationary, front_bounce]

func load_mane_from_data(mane_data : PonyIconManeMaster.ManeDataType, mane_colors : Array, num_mane_colors : int) -> void:
	# Set the internal mane_id of pony_base for later export.
	loaded_mane = mane_data.id
	
	set_mane_num_colors(num_mane_colors)
	
	# Set textures (method handles IFs for nulls)
	set_mane_textures(
		mane_data.bounce_back,
		mane_data.stationary_back,
		mane_data.stationary,
		mane_data.stationary_front,
		mane_data.bounce_front
	)
	
	# Propogate new num_colors, out_colors, and, if not keep mode, in_colors
	var in_colors : Array[Vector4] = []
	var out_colors : Array[Vector4] = []
	for i in range(0, len(mane_data.colors), 1):
		in_colors.append(Vector4(
			mane_data.colors[i].r, 
			mane_data.colors[i].g, 
			mane_data.colors[i].b, 
			mane_data.colors[i].a)
			)
		out_colors.append(Vector4(
			mane_colors[i].r, 
			mane_colors[i].g, 
			mane_colors[i].b, 
			mane_colors[i].a)
			)
	set_mane_colors_different_in(in_colors, out_colors)

func recolor_mane(color_id : int, new_color : Vector4):
	for m in get_mane_components():
		m.set_out_color(color_id, new_color)

func set_initial_mane_colors(colors : Array[Vector4]):
	if len(colors) <= 8 and len(colors) > 1:
		for m in get_mane_components():
			m.set_num_colors(len(colors))
			for i in range(0, len(colors)):
				m.set_in_color(i, colors[i])
				m.set_out_color(i, colors[i])

func set_mane_colors_different_in(in_colors : Array[Vector4], out_colors : Array[Vector4]):
	if len(in_colors) <= 8 and len(in_colors) > 1 and len(out_colors) == len(in_colors):
		for m in get_mane_components():
			m.set_num_colors(len(in_colors))
			for i in range(0, len(in_colors)):
				m.set_in_color(i, in_colors[i])
				m.set_out_color(i, out_colors[i])

func set_mane_num_colors(val : int):
	for m in get_mane_components():
		m.set_num_colors(val)

func set_tail_num_colors(val : int):
	tail.set_num_colors(val)

func load_tail_from_data(tail_data : PonyIconTailMaster.TailDataType, tail_colors : Array, num_tail_colors : int) -> void:
	# Set the internal mane_id of pony_base for later export.
	loaded_tail = tail_data.id
	
	set_tail_num_colors(num_tail_colors)
	
	# Set textures (method handles IFs for nulls)
	set_tail_texture(
		tail_data.sprite,
	)
	
	# Propogate new num_colors, out_colors, and, if not keep mode, in_colors
	var in_colors : Array[Vector4] = []
	var out_colors : Array[Vector4] = []
	for i in range(0, len(tail_data.colors), 1):
		in_colors.append(Vector4(
			tail_data.colors[i].r, 
			tail_data.colors[i].g, 
			tail_data.colors[i].b, 
			tail_data.colors[i].a)
			)
		out_colors.append(Vector4(
			tail_colors[i].r, 
			tail_colors[i].g, 
			tail_colors[i].b, 
			tail_colors[i].a)
			)
	set_mane_colors_different_in(in_colors, out_colors)

func recolor_tail(color_id : int, new_color : Vector4):
	tail.set_out_color(color_id, new_color)

func set_initial_tail_colors(colors : Array[Vector4]):
	if len(colors) <= 8 and len(colors) > 1:
		tail.set_num_colors(len(colors))
		for i in range(0, len(colors)):
			tail.set_in_color(i, colors[i])
			tail.set_out_color(i, colors[i])

func set_mane_textures(bb_sprite, bs_sprite, s_sprite, fs_sprite, fb_sprite):
	if bb_sprite:
		back_bounce.visible = true
		back_bounce.assign_sprite(bb_sprite)
	else:
		back_bounce.visible = false
	if bs_sprite:
		back_stationary.visible = true
		back_stationary.assign_sprite(bs_sprite)
	else:
		back_stationary.visible = false
	if s_sprite:
		stationary.visible = true
		stationary.assign_sprite(s_sprite)
	else:
		stationary.visible = false
	if fs_sprite:
		front_stationary.visible = true
		front_stationary.assign_sprite(fs_sprite)
	else:
		front_stationary.visible = false
	if fb_sprite:
		front_bounce.visible = true
		front_bounce.assign_sprite(fb_sprite)
	else:
		front_bounce.visible = false

func set_tail_texture(tail_sprite):
	if tail_sprite:
		tail.visible = true
		tail.assign_sprite(tail_sprite)
	else:
		tail.visible = false

func set_tail_colors_different_in(in_colors : Array[Vector4], out_colors : Array[Vector4]):
	if len(in_colors) <= 8 and len(in_colors) > 1 and len(out_colors) == len(in_colors):
		tail.set_num_colors(len(in_colors))
		for i in range(0, len(in_colors)):
			tail.set_in_color(i, in_colors[i])
			tail.set_out_color(i, out_colors[i])

func set_horn_enabled(val : bool):
	horn.visible = val

func set_wings_enabled(val : bool):
	wings.visible = val

func export_pony(horse_name : String, file_name : String, path_root : String, path : String):
	pony_importer_exporter.export_pony(horse_name, file_name, path_root, path)

func get_butt_mark_color_array() -> Array[String]:
	var out_arr : Array[String] = []
	
	if butt_mark.texture and butt_mark.texture.get_image():
		var butt_image : Image = butt_mark.texture.get_image()
		for y in range(0, 7):
			for x in range(0, 7):
				out_arr.append(butt_image.get_pixel(x, y).to_html())
	else:
		for i in range(0, 49):
			out_arr.append("00000000")
	return out_arr
