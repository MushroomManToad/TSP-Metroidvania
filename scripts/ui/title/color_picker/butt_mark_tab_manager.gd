class_name PonyCCButtMarkTabManager

extends MarginContainer

@onready var brush_button: ButtMarkControlButton = $ControlContainer/VBoxContainer/HBoxContainer/BrushButton
@onready var eraser_button: ButtMarkControlButton = $ControlContainer/VBoxContainer/HBoxContainer2/EraserButton
@onready var grid_button: ButtMarkControlButton = $ControlContainer/VBoxContainer/HBoxContainer2/GridButton
@onready var color_picker_button: PonyColorPickerButton = $ControlContainer/VBoxContainer/HBoxContainer/ColorPickerButton

@onready var grid_render: TextureRect = $ButtMarkBG/GridContainer/GridRender

@export var pony_base : PonyBase

@onready var butt_mark_draw_grid : Array[ButtMarkColorGridButton] = [
	$ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row0/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row1/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row2/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row3/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row4/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row5/ButtMarkColorGridButton7,
	$ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton2, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton3, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton4, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton5, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton6, $ButtMarkBG/GridContainer/VContainer/Row6/ButtMarkColorGridButton7
	]

const SMALL_PALLETE_BUTTON = preload("uid://cng3wvs4bbq14")

var active_color : Color = Color(1., 1., 1., 1.)
var eraser_active : bool = false

# LEAVE AS EVEN SPRITE SIZE
var bm_size : Vector2i = Vector2i(8, 8)

@onready var row_0: HBoxContainer = $PalleteContainer/VBoxContainer/Row0
@onready var row_1: HBoxContainer = $PalleteContainer/VBoxContainer/Row1
@onready var row_2: HBoxContainer = $PalleteContainer/VBoxContainer/Row2
@onready var row_3: HBoxContainer = $PalleteContainer/VBoxContainer/Row3

var colors_in_palette : Array[Color]
var palette_buttons : Array[SmallPalleteButton]

func _ready() -> void:
	brush_button.button_pressed = true
	grid_button.button_pressed = true

func update_butt_mark_image():
	var image = Image.create_empty(bm_size.x, bm_size.y, false, Image.FORMAT_RGBA8)
	
	for i in range(0, len(butt_mark_draw_grid)):
		if butt_mark_draw_grid[i].is_invisible:
			@warning_ignore("integer_division")
			image.set_pixel(i % 7, (i / 7) as int, Color(0.0, 0.0, 0.0, 0.0))
		else:
			@warning_ignore("integer_division")
			image.set_pixel(i % 7, (i / 7) as int, butt_mark_draw_grid[i].self_modulate)
	
	var image_texture = ImageTexture.create_from_image(image)
	
	pony_base.butt_mark.texture = image_texture

func update_palette():
	# Only update when palette doesn't contain active color
	# and we're coloring. That way you don't immediately lose a color you
	# erased all of.
	if not colors_in_palette.has(active_color) and not eraser_active:
		for pb in palette_buttons:
			pb.queue_free()
		palette_buttons.clear()
		
		colors_in_palette.clear()
		
		for bmb in butt_mark_draw_grid:
			if not colors_in_palette.has(bmb.self_modulate):
				colors_in_palette.append(bmb.self_modulate)
				var pb : SmallPalleteButton = SMALL_PALLETE_BUTTON.instantiate()
				pb.butt_mark_tab = self
				pb.set_color(bmb.self_modulate)
				if len(palette_buttons) < 12:
					row_0.add_child(pb)
				elif len(palette_buttons) < 24:
					row_1.add_child(pb)
				elif len(palette_buttons) < 36:
					row_2.add_child(pb)
				elif len(palette_buttons) < 48:
					row_3.add_child(pb)
				else:
					pb.queue_free()
				palette_buttons.append(pb)

func set_active_color(_id : int, new_color : Vector4):
	active_color = Color(new_color.x, new_color.y, new_color.z, new_color.w)
