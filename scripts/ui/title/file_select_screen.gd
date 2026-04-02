extends CanvasLayer

@onready var file_1: FileSelectButton = $MarginContainer/VBoxContainer/File1
@onready var file_2: FileSelectButton = $MarginContainer/VBoxContainer/File2
@onready var file_3: FileSelectButton = $MarginContainer/VBoxContainer/File3

var pressed_button : TextureButton

# TODO: Default to last loaded file rather than page 1
var last_loaded_file : int = 1

var page = 0

var is_pressed = false

func _ready() -> void:
	page = 0
	load_page_by_number(page)
	# Set focus to the last loaded file
	last_loaded_file_grab_focus()

func last_loaded_file_grab_focus():
	match ((last_loaded_file - 1) % 3):
		0: file_1.grab_focus()
		1: file_2.grab_focus()
		2: file_3.grab_focus()

func _process(_delta):
	if not is_pressed and (get_viewport().gui_get_focus_owner() == null or !get_viewport().gui_get_focus_owner().is_inside_tree()):
		get_viewport().gui_release_focus()
		last_loaded_file_grab_focus()
	if Input.is_action_just_pressed("ui_accept"):
		press_button()
		is_pressed = true
	if Input.is_action_just_released("ui_accept"):
		do_button_behavior()
		is_pressed = false
		if get_viewport().gui_get_focus_owner() == null:
			file_1.grab_focus()
	if Input.is_action_just_pressed("Back"):
		GameManager.load_title_screen()

func press_button():
	if get_viewport().gui_get_focus_owner() is TextureButton:
		pressed_button = get_viewport().gui_get_focus_owner()
	if file_1.has_focus():
		file_1.toggle_mode = true
		file_1.button_pressed = true
	elif file_2.has_focus():
		file_2.toggle_mode = true
		file_2.button_pressed = true
	elif file_3.has_focus():
		file_3.toggle_mode = true
		file_3.button_pressed = true
	if get_viewport().gui_get_focus_owner() != null:
		get_viewport().gui_get_focus_owner().release_focus()
	else:
		file_1.grab_focus()

func do_button_behavior():
	if pressed_button == file_1:
		file_1._on_pressed()
		file_1.grab_focus()
	elif pressed_button == file_2:
		file_2._on_pressed()
		file_2.grab_focus()
	elif pressed_button == file_3:
		file_3._on_pressed()
		file_3.grab_focus()

func load_page_by_number(page_num : int):
	# FILE 1
	if save_file_exists((page_num * 3)):
		# Load file renderer
		file_1.load_save_game_prompt(page_num)
	else:
		# Load new file prompt
		file_1.load_new_file_prompt(page_num)
	
	# FILE 2
	if save_file_exists(1 + (page_num * 3)):
		# Load file renderer
		file_2.load_save_game_prompt(page_num)
	else:
		# Load new file prompt
		file_2.load_new_file_prompt(page_num)
		
	# FILE 3
	if save_file_exists(2 + (page_num * 3)):
		# Load file renderer
		file_3.load_save_game_prompt(page_num)
	else:
		# Load new file prompt
		file_3.load_new_file_prompt(page_num)

func save_file_exists(id : int) -> bool:
	return GameManager.SAVE_MANAGER.file_exists(id)
