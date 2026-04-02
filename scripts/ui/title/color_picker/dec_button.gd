class_name PonyColorPickerDecimalButton

extends TextureButton

@onready var color_picker: PonyColorPicker = $"../../../../../.."
@onready var dec_text: LineEdit = $DecText

var valid_chars = "1234567890"

func propogate():
	color_picker.propogate(PonyColorPicker.PropogationType.DEC)


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		dec_text.grab_focus()


func validate_text():
	var input_text = dec_text.text
	# Clear whitespace and commas and periods (I see you Europe :3)
	input_text = input_text.replace(" ", "")
	input_text = input_text.replace(",", "")
	input_text = input_text.replace(".", "")
	
	var validated_flag = false
	# Either with or without a leading # or other char, text can still be validated.
	if len(input_text) <= 8 and len(input_text) > 0:
		var out_text = ""
		for c in input_text:
			if c in valid_chars:
				out_text = out_text + c
		input_text = out_text
		if len(input_text) <= 8 and len(input_text) > 0 and input_text as int < 16777216:
			validated_flag = true
	
	# Input is invalid and should be reset to old RGB.
	if not validated_flag:
		var rgb = color_picker.get_rgb_as_ints()
		var out_text = ""
		out_text += str((rgb.x * 65536 + rgb.y * 256 + rgb.z) as int)
		input_text = out_text
	dec_text.text = input_text


func _on_dec_text_focus_exited() -> void:
	button_pressed = false
	validate_text()
	propogate()


func _on_dec_text_text_submitted(_new_text: String) -> void:
	button_pressed = false
	validate_text()
	propogate()
