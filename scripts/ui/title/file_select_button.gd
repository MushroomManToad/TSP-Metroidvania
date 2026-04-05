class_name FileSelectButton

extends TextureButton

@onready var new_file: MarginContainer = $NewFile
@onready var save_display: MarginContainer = $SaveDisplay

var has_save_data : bool = false

@export var file_num : int
var page_num : int = 0

@onready var file_name: RichTextLabel = $SaveDisplay/VBoxContainer/MarginContainer2/Name

func load_new_file_prompt(page : int):
	new_file.visible = true
	save_display.visible = false
	has_save_data = false
	page_num = page

func load_save_game_prompt(page : int):
	new_file.visible = false
	save_display.visible = true
	has_save_data = true
	page_num = page
	# TODO: Load Char and Progress Sprite
	var json_as_dict = GameManager.PersistentInventory.get_char_dict(file_number())
	# Load Pone
	## pony_base.pony_importer_exporter.import_pony(json_as_dict)
	# Load Filename
	## pony_name.text = json_as_dict.get(PonyImporterExporter.id_pony_name, "FAILED TO LOAD NAME")
	## TODO: Load Save Progress Sprites/Data
	pass

func _on_pressed() -> void:
	if has_save_data:
		# Load savegame into actual game
		GameManager.GAME.clean_ui()
		GameManager.RuntimeStateHandler.load_save_game(file_number())
	else:
		# Load file creation page with correct filenum
		GameManager.RuntimeStateHandler.load_screen_by_id(file_number())
	pass # Replace with function body.

func file_number() -> int:
	return file_num + (page_num * 3)

func _on_mouse_entered() -> void:
	grab_focus()
