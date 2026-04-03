extends CanvasLayer

@onready var start_button: TextureButton = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/Start
@onready var settings_button: TextureButton = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/Settings
@onready var extras_button: TextureButton = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/Extras
@onready var quit_button: TextureButton = $UI/VBoxContainer/HBoxContainer2/VBoxContainer/Quit
@onready var secret_button: TextureButton = $UI/SecretButton

var pressed_button : TextureButton = start_button

var is_pressed : bool = false

func _ready() -> void:
	start_button.grab_focus()

func _process(_delta):
	if not is_pressed and (get_viewport().gui_get_focus_owner() == null or !get_viewport().gui_get_focus_owner().is_inside_tree()):
		get_viewport().gui_release_focus()
		start_button.grab_focus()
	if Input.is_action_just_pressed("ui_accept"):
		press_button()
		is_pressed = true
	if Input.is_action_just_released("ui_accept"):
		do_button_behavior()
		is_pressed = false
		if get_viewport().gui_get_focus_owner() == null:
			start_button.grab_focus()

func press_button():
	if get_viewport().gui_get_focus_owner() is TextureButton:
		pressed_button = get_viewport().gui_get_focus_owner()
	if start_button.has_focus():
		start_button.toggle_mode = true
		start_button.button_pressed = true
	elif settings_button.has_focus():
		settings_button.toggle_mode = true
		settings_button.button_pressed = true
	elif extras_button.has_focus():
		extras_button.toggle_mode = true
		extras_button.button_pressed = true
	elif quit_button.has_focus():
		quit_button.toggle_mode = true
		quit_button.button_pressed = true
	if get_viewport().gui_get_focus_owner() != null:
		get_viewport().gui_get_focus_owner().release_focus()
	else:
		start_button.grab_focus()

func do_button_behavior():
	if pressed_button == start_button:
		start_game()
		start_button.grab_focus()
	elif pressed_button == settings_button:
		open_settings()
		settings_button.grab_focus()
	elif pressed_button == extras_button:
		open_extras()
		extras_button.grab_focus()
	elif pressed_button == quit_button:
		quit_game()
		quit_button.grab_focus()

func start_game():
	# Load file_select_screen, unload title screen.
	start_button.toggle_mode = false
	start_button.button_pressed = false
	
	GameManager.RuntimeStateHandler.load_screen_by_id(Runtime_State_Handler.Menu.FILE_SELECT)

func open_settings():
	settings_button.toggle_mode = false
	settings_button.button_pressed = false
	# TODO: Settings Menu

func open_extras():
	extras_button.toggle_mode = false
	extras_button.button_pressed = false
	# TODO: Extras Menu
	pass

func quit_game():
	quit_button.toggle_mode = false
	quit_button.button_pressed = false
	# Exit game via ending scene tree
	get_tree().quit()

# Helper signals to set the hovered button to be focused so only 1 is focused at any time.
func _on_start_mouse_entered() -> void:
	start_button.grab_focus()
func _on_settings_mouse_entered() -> void:
	settings_button.grab_focus()
func _on_extras_mouse_entered() -> void:
	extras_button.grab_focus()
func _on_quit_mouse_entered() -> void:
	quit_button.grab_focus()

# Additional helper signal to ensure a button stays focused when mouse leaves after pressing.
func _on_start_mouse_exited() -> void:
	start_button.grab_focus()
func _on_settings_mouse_exited() -> void:
	settings_button.grab_focus()
func _on_extras_mouse_exited() -> void:
	extras_button.grab_focus()
func _on_quit_mouse_exited() -> void:
	quit_button.grab_focus()



# Signal catchers for each button when mouse interacted.
func _on_start_pressed() -> void:
	start_game()
func _on_settings_pressed() -> void:
	open_settings()
func _on_extras_pressed() -> void:
	open_extras()
func _on_quit_pressed() -> void:
	get_tree().quit()
