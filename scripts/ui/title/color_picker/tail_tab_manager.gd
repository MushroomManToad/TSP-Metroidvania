class_name PonyCCTailTabManager

extends MarginContainer

@onready var color_0: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color0
@onready var color_1: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color1
@onready var color_2: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color2
@onready var color_3: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color3
@onready var color_4: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color4
@onready var color_5: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color5
@onready var color_6: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color6
@onready var color_7: PonyColorPickerButton = $VBoxContainer/ColorsBGRect/MarginContainer/ColorsBox/Color7

@onready var row_0: HBoxContainer = $VBoxContainer/ManeButtonsBGRect/MarginContainer/VBoxContainer/Row0
@onready var row_1: HBoxContainer = $VBoxContainer/ManeButtonsBGRect/MarginContainer/VBoxContainer/Row1
@onready var row_2: HBoxContainer = $VBoxContainer/ManeButtonsBGRect/MarginContainer/VBoxContainer/Row2
@onready var row_3: HBoxContainer = $VBoxContainer/ManeButtonsBGRect/MarginContainer/VBoxContainer/Row3
@onready var row_4: HBoxContainer = $VBoxContainer/ManeButtonsBGRect/MarginContainer/VBoxContainer/Row4

const TAIL_MANE_BUTTON = preload("uid://ddoqw1feeydci")

@onready var pony_base: PonyBase = $"../../../../PonyRenderContainer/PonyBase"

var color_mode_keep = false

var loaded_tails_count : int = 0

var tail_buttons : Dictionary[String, TailManeButton]
var color_buttons : Array[PonyColorPickerButton]

func _ready() -> void:
	color_buttons = [color_0, color_1, color_2, color_3, color_4, color_5, color_6, color_7]
	load_tail_buttons()

func load_tail_buttons():
	for tail_data in GameManager.PONY_ICON_RESOURCE_MANAGER.tail_types.values():
		add_tail_button(tail_data)
	tail_buttons.get("twilight_sparkle").button_pressed = true

func add_tail_button(tail_data : PonyIconTailMaster.TailDataType):
	var tail_button : TailManeButton = TAIL_MANE_BUTTON.instantiate()
	tail_button.set_tail_data(tail_data)
	tail_button.set_pony_base(pony_base)
	tail_button.set_tail_tab_manager(self)
	
	## Line wrapping when there's too many tails
	# 12 Per row.
	if loaded_tails_count < 12:
		row_0.add_child(tail_button)
	elif loaded_tails_count < 24:
		row_1.add_child(tail_button)
	elif loaded_tails_count < 36:
		row_2.add_child(tail_button)
	elif loaded_tails_count < 48:
		row_3.add_child(tail_button)
	elif loaded_tails_count < 60:
		row_4.add_child(tail_button)
	loaded_tails_count += 1
	tail_buttons.set(tail_data.id, tail_button)

func depress_all():
	for tmb in tail_buttons.values():
		tmb.set_pressed_no_signal(false)

func unlock_all():
	for cb in color_buttons:
		cb.disable_lock()

func disable_button(pcpb : PonyColorPickerButton):
	pcpb.visible = false
	pcpb.process_mode = Node.PROCESS_MODE_DISABLED

func enable_button(pcpb : PonyColorPickerButton):
	pcpb.process_mode = Node.PROCESS_MODE_INHERIT
	pcpb.visible = true
