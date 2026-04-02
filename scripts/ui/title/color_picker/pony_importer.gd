class_name PonyImporter

extends FileDialog

var character_creator : CharacterCreator

func _on_file_selected(path: String) -> void:
	# Load into character creator buttons and make sure it propogates to PoneBase
	character_creator.load_pony_from_file(path)
