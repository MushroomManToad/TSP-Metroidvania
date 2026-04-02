class_name ButtMarkControlButton

extends TextureButton

@export var butt_mark_tab : PonyCCButtMarkTabManager

@export_category("0-Brush 1-Eraser 2-Grid")
@export var mode : int = 0

func _ready() -> void:
	pass

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		match mode:
			0:
				butt_mark_tab.eraser_button.set_pressed_no_signal(false)
				butt_mark_tab.eraser_active = false
			1:
				butt_mark_tab.brush_button.set_pressed_no_signal(false)
				butt_mark_tab.eraser_active = true
			2:
				butt_mark_tab.grid_render.visible = true
	else:
		if mode < 2:
			set_pressed_no_signal(true)
		else:
			butt_mark_tab.grid_render.visible = false
