class_name SmallPalleteButton

extends TextureButton

@export var butt_mark_tab : PonyCCButtMarkTabManager

func set_color(color : Color):
	self_modulate = color



func _on_pressed() -> void:
	butt_mark_tab.active_color = self_modulate
	butt_mark_tab.color_picker_button.update_color(self_modulate)
