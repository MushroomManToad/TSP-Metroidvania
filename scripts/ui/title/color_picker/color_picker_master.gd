class_name PonyColorPicker

extends CanvasLayer

@onready var h_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/HSelector
@onready var s_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/SSelector
@onready var v_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/VSelector
@onready var r_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/RSelector
@onready var g_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/GSelector
@onready var b_selector: PonyColorPickerSelector = $MarginContainer/ColorPickerBG/LayoutMap/RightSideButtons/ButtonsAlign/BSelector

@onready var hex_button: PonyHexidecimalColorPickerButton = $MarginContainer/ColorPickerBG/LayoutMap/BottomButtons/HBoxContainer/HexButton
@onready var dec_button: PonyColorPickerDecimalButton = $MarginContainer/ColorPickerBG/LayoutMap/BottomButtons/HBoxContainer/DecButton

@onready var sv_picker_container: PonySVPickerContainer = $MarginContainer/ColorPickerBG/LayoutMap/SVPickerContainer

@onready var sv_picker_rect: TextureRect = $MarginContainer/ColorPickerBG/LayoutMap/SVPickerContainer/SVPickerRect

var init_rgb = Vector3(255, 0, 0)
var modulate_source : PonyColorPickerButton

func _ready() -> void:
	assign_rgb_from_vec(init_rgb)
	
	propogate(PropogationType.RGB)

func propogate(from : PropogationType):
	match from:
		PropogationType.HSV:
			var hue = h_selector.text.text as int
			var saturation = (s_selector.text.text as int) as float / 255.0
			var value = (v_selector.text.text as int) as float / 255.0
			
			var rgb = get_rgb_from_hsv(hue, saturation, value)
			
			rgb = rgb.clampf(0.0, 1.0)
			
			assign_rgb_from_vec(rgb)
			
			sv_picker_container.set_current_sv_pointer_value_by_norm(Vector2(saturation, value))
			sv_picker_container.set_current_h_pointer_value(hue)
			(sv_picker_rect.material as ShaderMaterial).set_shader_parameter("hue", hue)
			
			assign_hex_from_rgb(rgb)
			assign_dec_from_rgb(rgb)
			
		PropogationType.RGB:
			var red = (r_selector.text.text as int) as float / 255.0
			var green = (g_selector.text.text as int) as float / 255.0
			var blue = (b_selector.text.text as int) as float / 255.0
			
			var hsv = get_hsv_from_rgb(red, green, blue)
			
			assign_hsv_from_vec(hsv)
			
			sv_picker_container.set_current_sv_pointer_value_by_norm(Vector2(hsv.y, hsv.z))
			sv_picker_container.set_current_h_pointer_value(hsv.x)
			
			(sv_picker_rect.material as ShaderMaterial).set_shader_parameter("hue", hsv.x)
			
			var rgb : Vector3 = Vector3(red, green, blue)
			rgb = rgb.clampf(0.0, 1.0)
			assign_hex_from_rgb(rgb)
			assign_dec_from_rgb(rgb)
			
		PropogationType.SELECTION:
			var hue = sv_picker_container.get_current_hue()
			var sv = sv_picker_container.get_current_sv_pointer_value()
			var saturation = sv.x
			var value = sv.y
			
			var rgb = get_rgb_from_hsv(hue, saturation, value)
			
			rgb = rgb.clampf(0.0, 1.0)
			
			assign_rgb_from_vec(rgb)
			
			assign_hsv_from_vec(Vector3(hue, saturation, value))
			
			(sv_picker_rect.material as ShaderMaterial).set_shader_parameter("hue", hue)
			
			assign_hex_from_rgb(rgb)
			assign_dec_from_rgb(rgb)
			
		PropogationType.HEX:
			var hex_string = hex_button.hex_text.text
			var rgb_color = Color.html(hex_string)
			var rgb : Vector3 = Vector3(rgb_color.r, rgb_color.g, rgb_color.b)
			
			assign_rgb_from_vec(rgb)
			
			var hsv = get_hsv_from_rgb(rgb.x, rgb.y, rgb.z)
			assign_hsv_from_vec(hsv)
			
			sv_picker_container.set_current_sv_pointer_value_by_norm(Vector2(hsv.y, hsv.z))
			sv_picker_container.set_current_h_pointer_value(hsv.x)
			
			(sv_picker_rect.material as ShaderMaterial).set_shader_parameter("hue", hsv.x)
			
			assign_dec_from_rgb(rgb)
			
		PropogationType.DEC:
			var decimal = dec_button.dec_text.text as int
			var red = (decimal >> 16) & 0xFF
			var green = (decimal >> 8) & 0xFF
			var blue = decimal & 0xFF
			
			var rgb = Vector3(red / 255.0, green / 255.0, blue / 255.0)
			
			assign_rgb_from_vec(rgb)
			
			var hsv = get_hsv_from_rgb(rgb.x, rgb.y, rgb.z)
			assign_hsv_from_vec(hsv)
			
			sv_picker_container.set_current_sv_pointer_value_by_norm(Vector2(hsv.y, hsv.z))
			sv_picker_container.set_current_h_pointer_value(hsv.x)
			
			(sv_picker_rect.material as ShaderMaterial).set_shader_parameter("hue", hsv.x)
			
			assign_hex_from_rgb(rgb)
	if modulate_source != null:
		var red = (r_selector.text.text as int) as float / 255.0
		var green = (g_selector.text.text as int) as float / 255.0
		var blue = (b_selector.text.text as int) as float / 255.0
		modulate_source.self_modulate = Color(red, green, blue, 1.0)
		modulate_source.update_color(Color(red, green, blue, 1.0))

enum PropogationType {
	HSV,
	RGB,
	SELECTION,
	HEX,
	DEC,
}

# Formula for getting rgb given hsv ([0,359], [0.,1.], [0.,1.])
func get_rgb_from_hsv(hue : int, saturation : float, value : float):
	var chroma = saturation * value
	var h_prime = hue as float / 60.
	var x = chroma * (1. - abs(fmod(h_prime, 2.) - 1.))
	
	var rgb_prime = Vector3(0., 0., 0.)
	if 0. <= h_prime && h_prime < 1. : rgb_prime = Vector3(chroma, x, 0.)
	elif 1. <= h_prime && h_prime < 2. : rgb_prime = Vector3(x, chroma, 0.)
	elif 2. <= h_prime && h_prime < 3. : rgb_prime = Vector3(0., chroma, x)
	elif 3. <= h_prime && h_prime < 4. : rgb_prime = Vector3(0., x, chroma)
	elif 4. <= h_prime && h_prime < 5. : rgb_prime = Vector3(x, 0., chroma)
	elif 5. <= h_prime && h_prime < 6. : rgb_prime = Vector3(chroma, 0., x)
	
	var m = value - chroma
	
	var rgb = Vector3(rgb_prime.x + m, rgb_prime.y + m, rgb_prime.z + m)
	
	return rgb

func get_hsv_from_rgb(red, green, blue) -> Vector3:
	var x_max = max(red, green, blue)
	var value = x_max
	var x_min = min(red, green, blue)
	var chroma = x_max - x_min
	var hue = 0
	if chroma == 0.0:
		pass
	elif value == red:
		hue = 60.0 * fposmod((green - blue) / chroma, 6)
	elif value == green:
		hue = 60.0 * (((blue - red) / chroma) + 2)
	elif value == blue:
		hue = 60.0 * (((red - green) / chroma) + 4)
	
	var saturation = 0.0
	if value != 0.0:
		saturation = chroma / value
	
	return Vector3(hue, saturation, value)

func assign_rgb_from_vec(rgb : Vector3):
	r_selector.text.text = str((rgb.x * 255.0) as int)
	g_selector.text.text = str((rgb.y * 255.0) as int)
	b_selector.text.text = str((rgb.z * 255.0) as int)
	
	r_selector.clamp_text_value(r_selector.text.text)
	g_selector.clamp_text_value(g_selector.text.text)
	b_selector.clamp_text_value(b_selector.text.text)

func assign_hsv_from_vec(hsv : Vector3):
	h_selector.text.text = str(hsv.x as int)
	s_selector.text.text = str((hsv.y * 255.0) as int)
	v_selector.text.text = str((hsv.z * 255.0) as int)
	
	h_selector.clamp_text_value(h_selector.text.text)
	s_selector.clamp_text_value(s_selector.text.text)
	v_selector.clamp_text_value(v_selector.text.text)

func assign_hex_from_rgb(rgb : Vector3):
	var color : Color = Color(rgb.x, rgb.y, rgb.z, 1.0)
	var hex = color.to_html(false)
	hex_button.hex_text.text = "#" + str(hex)

func assign_dec_from_rgb(rgb : Vector3):
	var val = (rgb.x * 65536.0 * 255.0) as int + (rgb.y * 256.0 * 255.0) as int + (rgb.z * 255.0) as int
	dec_button.dec_text.text = str(val)

func get_rgb_as_ints() -> Vector3:
	var rgb : Vector3 = Vector3(r_selector.text.text as int, g_selector.text.text as int, b_selector.text.text as int)
	return rgb

func close_ui():
	queue_free()
