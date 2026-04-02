class_name PonySVPickerContainer

extends MarginContainer

@onready var sv_picker_rect: TextureRect = $SVPickerRect

var is_dragging = false

@export var bounds_x = Vector2(0.0, 127.0)
@export var bounds_y = Vector2(0.0, 127.0)

@export var bounds_h = Vector2(0.0, 127.5)

@onready var sv_indicator_container: MarginContainer = $"../SVIndicatorContainer"
@onready var color_picker: PonyColorPicker = $"../../../.."
@onready var h_indicator_container: MarginContainer = $"../HIndicatorContainer"

var current_sv_location = Vector2(0, 0)
var current_h_location = 0.0

func _on_sv_picker_rect_gui_input(event: InputEvent) -> void:
	# Detect Click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var click_pos = event.position
			update_marker_to(click_pos)
		else:
			# Release on release
			is_dragging = false

	# Detect Drag (while mouse button is down)
	elif event is InputEventMouseMotion and is_dragging:
		var click_pos = event.position
		update_marker_to(click_pos)

func update_marker_to(click_pos : Vector2):
	# First, clamp click_pos
	click_pos.x = min(bounds_x.y, click_pos.x)
	click_pos.x = max(bounds_x.x, click_pos.x)
	click_pos.y = min(bounds_y.y, click_pos.y)
	click_pos.y = max(bounds_y.x, click_pos.y)
	
	current_sv_location = click_pos
	
	click_pos = Vector2i(click_pos.x as int, click_pos.y as int)
	
	sv_indicator_container.add_theme_constant_override("margin_left", 3 + click_pos.x as int)
	sv_indicator_container.add_theme_constant_override("margin_top", 3 + click_pos.y as int)
	
	color_picker.propogate(PonyColorPicker.PropogationType.SELECTION)

func get_current_sv_pointer_value() -> Vector2:
	var normalized_val = current_sv_location
	normalized_val.x = normalized_val.x / 127.0
	normalized_val.y = normalized_val.y / 127.0
	return Vector2(normalized_val.x, 1. - normalized_val.y)

func set_current_sv_pointer_value_by_norm(sv_norm : Vector2) -> void:
	sv_indicator_container.add_theme_constant_override("margin_left", 3 + ((sv_norm.x * 127.0) as int))
	sv_indicator_container.add_theme_constant_override("margin_top", 3 + (((1 - sv_norm.y) * 127.0) as int))
	current_sv_location = Vector2(((sv_norm.x * 128.0) as int), (((1 - sv_norm.y) * 128.0) as int))


func _on_h_picker_rect_gui_input(event: InputEvent) -> void:
	# Detect Click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var click_pos = event.position
			update_h_marker_to(click_pos.y)
		else:
			# Release on release
			is_dragging = false

	# Detect Drag (while mouse button is down)
	elif event is InputEventMouseMotion and is_dragging:
		var click_pos = event.position
		update_h_marker_to(click_pos.y)

func update_h_marker_to(click_pos : float):
	# First, clamp click_pos
	click_pos = min(bounds_h.y, click_pos)
	click_pos = max(bounds_h.x, click_pos)
	
	current_h_location = click_pos
	
	click_pos = click_pos as int
	
	h_indicator_container.add_theme_constant_override("margin_top", 4 + click_pos as int)
	
	color_picker.propogate(PonyColorPicker.PropogationType.SELECTION)

func get_current_hue() -> float:
	var normalized_val = current_h_location / 128.0
	return normalized_val * 360.0

func set_current_h_pointer_value(hue : float) -> void:
	h_indicator_container.add_theme_constant_override("margin_top", 4 + (((hue as float / 360.0) * 128.0) as int))
	current_h_location = (((hue as float / 360.0) * 128.0) as int)
