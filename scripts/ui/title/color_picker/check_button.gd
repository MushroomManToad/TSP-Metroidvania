extends TextureButton


@onready var color_picker: PonyColorPicker = $"../../../../../.."



func _on_pressed() -> void:
	color_picker.close_ui()


func _on_mouse_entered() -> void:
	grab_focus()


func _on_mouse_exited() -> void:
	release_focus()
