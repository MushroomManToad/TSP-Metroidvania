extends TextureButton

@onready var character_creator: CharacterCreator = $"../../../.."

func _on_pressed() -> void:
	# Export pony to pony save location
	character_creator.pony_base.export_pony(character_creator.name_input.text, "pony_save_" + str(character_creator.file_num), "user://", GameManager.saves_local_path)
	# Create blank save file
	GameManager.SAVE_MANAGER.create_blank_save(character_creator.file_num)
	# Call standard start_game function
	GameManager.start_game(character_creator.file_num)
