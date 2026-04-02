class_name PonyHexidecimalColorPickerButton

extends TextureButton

@onready var color_picker: PonyColorPicker = $"../../../../../.."

@onready var hex_text: LineEdit = $HexText

var valid_chars = "1234567890ABCDEF"

func propogate():
	color_picker.propogate(PonyColorPicker.PropogationType.HEX)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		hex_text.grab_focus()


func validate_text():
	var input_text = hex_text.text
	# Clear whitespace
	input_text = input_text.replace(" ", "")
	# Lowercase
	input_text = input_text.to_upper()
	
	var validated_flag = false
	# Either with or without a leading # or other char, text can still be validated.
	if len(input_text) == 6 or len(input_text) == 7:
		var out_text = "#"
		for c in input_text:
			if c in valid_chars:
				out_text = out_text + c
		input_text = out_text
		if len(input_text) == 7:
			validated_flag = true
	
	# Input is invalid and should be reset to old RGB.
	if not validated_flag:
		var rgb = color_picker.get_rgb_as_ints()
		var out_text = "#"
		out_text += int_to_hex(rgb.x)
		out_text += int_to_hex(rgb.y)
		out_text += int_to_hex(rgb.z)
		input_text = out_text
	hex_text.text = input_text

func int_to_hex(val : int) -> String:
	return "%02X" % val

func _on_hex_text_focus_exited() -> void:
	button_pressed = false
	validate_text()
	propogate()


func _on_hex_text_text_submitted(_new_text: String) -> void:
	button_pressed = false
	validate_text()
	propogate()
