class_name PonyColorPickerButton

extends TextureRect

const color_picker = preload("uid://ys5fiq47d4uw")

@export_range(0, 7, 1) var color_id : int = 0

@export var target_node : Node
@export var target_function : String

signal update_locked

@export var has_lock : bool = false
@export var lock_source : PonyColorPickerButton
# What the ratio of this button's value should be compared to the source.
@export var val_factor : float = 1.0
@export var sat_factor : float = 1.0
@export var hue_offset : float = 0.0

var is_locked = false

@onready var lock_button: TextureButton = $LockButton

func _ready() -> void:
	if has_lock:
		enable_lock(true)
	update_locked.emit()

func enable_lock(should_lock : bool):
	is_locked = should_lock
	lock_button.visible = true
	lock_button.process_mode = Node.PROCESS_MODE_INHERIT
	lock_source.update_locked.connect(update_from_source)

func disconnect_lock():
	if lock_source != null:
		lock_source.update_locked.disconnect(update_from_source)
		lock_source = null

func disable_lock():
	disconnect_lock()
	is_locked = false
	lock_button.visible = false
	lock_button.process_mode = Node.PROCESS_MODE_DISABLED

func _on_texture_button_pressed() -> void:
	if not is_locked:
		var cps : PonyColorPicker = color_picker.instantiate()
		cps.init_rgb = Vector3(self_modulate.r, self_modulate.g, self_modulate.b)
		cps.modulate_source = self
		GameManager.load_into_game(cps)

func update_color(newColor : Color):
	self_modulate = newColor
	if target_node:
		var callable = Callable(target_node, target_function)
		callable.call(color_id, Vector4(newColor.r, newColor.g, newColor.b, newColor.a))
	update_locked.emit()

func update_from_source():
	if is_locked:
		var color : Color = lock_source.self_modulate
		color.h = fposmod(color.h + hue_offset, 1.0)
		color.s = clampf(color.s * sat_factor, 0., 1.)
		color.v = clampf(color.v * val_factor, 0., 1.)
		update_color(color)

func set_hsv_offset(h : float, s : float, v : float):
	hue_offset = h
	val_factor = v
	sat_factor = s

func _on_lock_button_toggled(toggled_on: bool) -> void:
	is_locked = not toggled_on

func get_color():
	return self_modulate
