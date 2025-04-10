extends IInteractable

@export var scene_to_load : String
@export var player_spawn_position : Vector2

func on_interact() -> void:
	GameManager.LevelManager.load_scene(scene_to_load, player_spawn_position)

func on_ready() -> void:
	pass
