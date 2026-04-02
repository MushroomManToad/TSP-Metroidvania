extends TextureButton

const PONY_IMPORTER = preload("uid://wb46pov585u1")

@export var character_creator : CharacterCreator

func _on_pressed() -> void:
	var pony_importer : PonyImporter = PONY_IMPORTER.instantiate()
	pony_importer.character_creator = character_creator
	character_creator.add_child(pony_importer)
