class_name FileSelectButton

extends TextureButton

@onready var new_file: MarginContainer = $NewFile
@onready var save_display: MarginContainer = $SaveDisplay

var has_save_data : bool = false

@export var file_num : int
var page_num : int = 0

@onready var pony_name: RichTextLabel = $SaveDisplay/VBoxContainer/MarginContainer2/Name
@onready var pony_base: PonyBase = $SaveDisplay/VBoxContainer/MarginContainer/PonyBase

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
	# Load Horse and Progress Sprite
	if FileAccess.file_exists(get_pony_filepath(page)):
		var json_as_text = FileAccess.get_file_as_string(get_pony_filepath(page))
		var json_as_dict = JSON.parse_string(json_as_text)
		if json_as_dict is Dictionary:
			# Load Pone
			pony_base.pony_importer_exporter.import_pony(json_as_dict)
			# Load Filename
			pony_name.text = json_as_dict.get(PonyImporterExporter.id_pony_name, "FAILED TO LOAD NAME")
	else:
		pony_name.text = "ERROR READING FILE"
	## TODO: Load Save Progress Sprites/Data
	pass

func get_pony_filepath(page : int) -> String:
	return GameManager.USER + GameManager.saves_local_path + "/" + \
		GameManager.SAVE_MANAGER.save_name + str(page * 3 + file_num) + \
		GameManager.SAVE_MANAGER.pony_ext

func _on_pressed() -> void:
	if has_save_data:
		# Load savegame into actual game
		GameManager.start_game(file_number())
	else:
		# Load file creation page with correct filenum
		GameManager.load_character_creator_by_number(file_number())
	pass # Replace with function body.

func file_number() -> int:
	return file_num + (page_num * 3)

func _on_mouse_entered() -> void:
	grab_focus()
