extends TextureButton

@export var pony_base : PonyBase
@export var character_creator : CharacterCreator

func _on_pressed() -> void:
	pony_base.export_pony(character_creator.name_input.text, character_creator.name_input.text, "user://", GameManager.character_local_path)
