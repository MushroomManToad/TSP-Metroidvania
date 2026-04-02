class_name PonyCCMainUIBox

extends MarginContainer

@onready var body_tab: TextureButton = $HBoxContainer/VBoxContainer/BodyTab
@onready var head_tab: TextureButton = $HBoxContainer/VBoxContainer/HeadTab
@onready var mane_tab: TextureButton = $HBoxContainer/VBoxContainer/ManeTab
@onready var tail_tab: TextureButton = $HBoxContainer/VBoxContainer/TailTab
@onready var accessories_tab: TextureButton = $HBoxContainer/VBoxContainer/AccessoriesTab
@onready var butt_mark_tab: TextureButton = $HBoxContainer/VBoxContainer/ButtMarkTab

@onready var body_tab_container: MarginContainer = $HBoxContainer/MainUIBG/BodyTab
@onready var head_tab_container: MarginContainer = $HBoxContainer/MainUIBG/HeadTab
@onready var mane_tab_container: MarginContainer = $HBoxContainer/MainUIBG/ManeTab
@onready var tail_tab_container: MarginContainer = $HBoxContainer/MainUIBG/TailTab
@onready var accessories_tab_container: MarginContainer = $HBoxContainer/MainUIBG/AccessoriesTab
@onready var butt_mark_tab_container: MarginContainer = $HBoxContainer/MainUIBG/ButtMarkTab

func _ready() -> void:
	depress_all()
	_on_body_tab_toggled(true)

# Grab focus on mouse entered, release on exit
func _on_body_tab_mouse_entered() -> void:
	if not body_tab.button_pressed:
		body_tab.grab_focus()
func _on_head_tab_mouse_entered() -> void:
	if not head_tab.button_pressed:
		head_tab.grab_focus()
func _on_mane_tab_mouse_entered() -> void:
	if not mane_tab.button_pressed:
		mane_tab.grab_focus()
func _on_tail_tab_mouse_entered() -> void:
	if not tail_tab.button_pressed:
		tail_tab.grab_focus()
func _on_accessories_tab_mouse_entered() -> void:
	if not accessories_tab.button_pressed:
		accessories_tab.grab_focus()
func _on_butt_mark_tab_mouse_entered() -> void:
	if not butt_mark_tab.button_pressed:
		butt_mark_tab.grab_focus()
func _on_body_tab_mouse_exited() -> void:
	if not body_tab.button_pressed:
		body_tab.release_focus()
func _on_head_tab_mouse_exited() -> void:
	if not head_tab.button_pressed:
		head_tab.release_focus()
func _on_mane_tab_mouse_exited() -> void:
	if not mane_tab.button_pressed:
		mane_tab.release_focus()
func _on_tail_tab_mouse_exited() -> void:
	if not tail_tab.button_pressed:
		tail_tab.release_focus()
func _on_accessories_tab_mouse_exited() -> void:
	if not accessories_tab.button_pressed:
		accessories_tab.release_focus()
func _on_butt_mark_tab_mouse_exited() -> void:
	if not butt_mark_tab.button_pressed:
		butt_mark_tab.release_focus()

func depress_all():
	# Depress Buttons
	body_tab.set_pressed_no_signal(false)
	head_tab.set_pressed_no_signal(false)
	mane_tab.set_pressed_no_signal(false)
	tail_tab.set_pressed_no_signal(false)
	accessories_tab.set_pressed_no_signal(false)
	butt_mark_tab.set_pressed_no_signal(false)
	# Unload and hide all UI
	body_tab_container.visible = false
	body_tab_container.process_mode = Node.PROCESS_MODE_DISABLED
	head_tab_container.visible = false
	head_tab_container.process_mode = Node.PROCESS_MODE_DISABLED
	mane_tab_container.visible = false
	mane_tab_container.process_mode = Node.PROCESS_MODE_DISABLED
	tail_tab_container.visible = false
	tail_tab_container.process_mode = Node.PROCESS_MODE_DISABLED
	accessories_tab_container.visible = false
	accessories_tab_container.process_mode = Node.PROCESS_MODE_DISABLED
	butt_mark_tab_container.visible = false
	butt_mark_tab_container.process_mode = Node.PROCESS_MODE_DISABLED

func _on_body_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		body_tab.set_pressed_no_signal(true)
		# Load body tab UI
		body_tab_container.visible = true
		body_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		body_tab.set_pressed_no_signal(true)



func _on_head_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		head_tab.set_pressed_no_signal(true)
		# Load body tab UI
		head_tab_container.visible = true
		head_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		head_tab.set_pressed_no_signal(true)


func _on_mane_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		mane_tab.set_pressed_no_signal(true)
		# Load body tab UI
		mane_tab_container.visible = true
		mane_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		mane_tab.set_pressed_no_signal(true)


func _on_tail_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		tail_tab.set_pressed_no_signal(true)
		# Load body tab UI
		tail_tab_container.visible = true
		tail_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		tail_tab.set_pressed_no_signal(true)


func _on_accessories_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		accessories_tab.set_pressed_no_signal(true)
		# Load body tab UI
		accessories_tab_container.visible = true
		accessories_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		accessories_tab.set_pressed_no_signal(true)


func _on_butt_mark_tab_toggled(toggled_on: bool) -> void:
	if toggled_on:
		depress_all()
		butt_mark_tab.set_pressed_no_signal(true)
		# Load body tab UI
		butt_mark_tab_container.visible = true
		butt_mark_tab_container.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		butt_mark_tab.set_pressed_no_signal(true)
