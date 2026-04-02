class_name PonyCCManeTabManager

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

const MANE_TAIL_BUTTON = preload("uid://d3rpjuhgh7hpy")

@onready var pony_base: PonyBase = $"../../../../PonyRenderContainer/PonyBase"

var color_mode_keep = false

var loaded_manes_count : int = 0

var mane_buttons : Dictionary[String, ManeTailButton]
var color_buttons : Array[PonyColorPickerButton]

func _ready() -> void:
	color_buttons = [color_0, color_1, color_2, color_3, color_4, color_5, color_6, color_7]
	load_mane_buttons()

func load_mane_buttons():
	for mane_data in GameManager.PONY_ICON_RESOURCE_MANAGER.mane_types.values():
		add_mane_button(mane_data)
	mane_buttons.get("twilight_sparkle").button_pressed = true

func add_mane_button(mane_data : PonyIconManeMaster.ManeDataType):
	var mane_button : ManeTailButton = MANE_TAIL_BUTTON.instantiate()
	mane_button.set_mane_data(mane_data)
	mane_button.set_pony_base(pony_base)
	mane_button.set_mane_tab_manager(self)
	
	## Line wrapping when there's too many manes
	# 12 Per row.
	if loaded_manes_count < 12:
		row_0.add_child(mane_button)
	elif loaded_manes_count < 24:
		row_1.add_child(mane_button)
	elif loaded_manes_count < 36:
		row_2.add_child(mane_button)
	elif loaded_manes_count < 48:
		row_3.add_child(mane_button)
	elif loaded_manes_count < 60:
		row_4.add_child(mane_button)
	loaded_manes_count += 1
	mane_buttons.set(mane_data.id, mane_button)

func depress_all():
	for mtb in mane_buttons.values():
		mtb.set_pressed_no_signal(false)

func unlock_all():
	for cb in color_buttons:
		cb.disable_lock()

func disable_button(pcpb : PonyColorPickerButton):
	pcpb.visible = false
	pcpb.process_mode = Node.PROCESS_MODE_DISABLED

func enable_button(pcpb : PonyColorPickerButton):
	pcpb.process_mode = Node.PROCESS_MODE_INHERIT
	pcpb.visible = true
