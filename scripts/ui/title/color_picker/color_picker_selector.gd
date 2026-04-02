class_name PonyColorPickerSelector

extends HBoxContainer

@onready var plus: TextureButton = $Plus
@onready var text_button_bg: TextureButton = $TextButtonBG
@onready var text: LineEdit = $TextButtonBG/Text
@onready var minus: TextureButton = $Minus

@onready var color_picker: PonyColorPicker = $"../../../../../.."

@export var bounds : Vector2i = Vector2i(0, 255)

@export var propogation_type : PonyColorPicker.PropogationType

func add_to_text(val : int):
	if val > 0:
		text.text = str(min(text.text as int + val, bounds.y))
	else:
		text.text = str(max(text.text as int + val, bounds.x))
	propogate()

func _on_plus_pressed() -> void:
	if Input.is_action_pressed("Shift"):
		add_to_text(25)
	elif Input.is_action_pressed("Ctrl"):
		add_to_text(5)
	else:
		add_to_text(1)

func _on_minus_pressed() -> void:
	if Input.is_action_pressed("Shift"):
		add_to_text(-25)
	elif Input.is_action_pressed("Ctrl"):
		add_to_text(-5)
	else:
		add_to_text(-1)

func _on_plus_mouse_entered() -> void:
	plus.grab_focus()

func _on_minus_mouse_entered() -> void:
	minus.grab_focus()


func _on_text_button_bg_toggled(toggled_on: bool) -> void:
	if toggled_on:
		text.grab_focus()


func clamp_text_value(input_text : String) -> void:
	var clamped_val : int = input_text as int
	clamped_val = max(clamped_val, bounds.x)
	clamped_val = min(clamped_val, bounds.y)
	text.text = str(clamped_val)


func _on_text_text_submitted(new_text: String) -> void:
	text_button_bg.button_pressed = false
	clamp_text_value(new_text)
	propogate()


func _on_text_focus_exited() -> void:
	text_button_bg.button_pressed = false
	var final_text = ""
	for c in text.text:
		if c.is_valid_int():
			final_text = final_text + c
	if final_text == "":
		final_text = "0"
	clamp_text_value(final_text)
	propogate()

func propogate():
	color_picker.propogate(propogation_type)


func _on_plus_mouse_exited() -> void:
	plus.release_focus()


func _on_minus_mouse_exited() -> void:
	minus.release_focus()
