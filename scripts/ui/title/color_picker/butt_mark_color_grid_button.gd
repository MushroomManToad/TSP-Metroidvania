class_name ButtMarkColorGridButton

extends TextureButton

@export var butt_mark_tab : PonyCCButtMarkTabManager

var is_invisible = true

func set_invisible():
	self_modulate = Color(1., 1., 1., 1.)
	(texture_normal as AtlasTexture).region.position.y = 16.0
	is_invisible = true

func set_color(color : Color):
	self_modulate = color
	(texture_normal as AtlasTexture).region.position.y = 0.0
	is_invisible = false


func _on_pressed() -> void:
	if butt_mark_tab.eraser_active:
		set_invisible()
	else:
		set_color(butt_mark_tab.active_color)
	butt_mark_tab.update_butt_mark_image()
	butt_mark_tab.update_palette()
