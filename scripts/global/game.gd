class_name Game

extends Node

@onready var game_root: Node2D = $MainViewport/Viewport/GameRoot
@onready var gui: CanvasLayer = $GUI

func _ready() -> void:
	GameManager.GAME = self

func load_main_scene(stage_name : String):
	# Queuefree old level (if it exists)
	if GameManager.LevelManager.loaded_scene:
		GameManager.LevelManager.loaded_scene.queue_free()
	# Load new level ## TODO: Async for lag reasons?
	var new_stage = load("scenes/stage/" + stage_name + ".tscn").instantiate()
	game_root.call_deferred("add_child", new_stage)
	GameManager.LevelManager.loaded_scene = new_stage

func set_ui_layer(scene_name : String):
	clean_ui()
	add_layer_to_ui(scene_name)

func add_layer_to_ui(scene_name : String):
	var ui_layer = load(scene_name).instantiate()
	gui.call_deferred("add_child", ui_layer)

func clean_ui():
	for u in gui.get_children():
		u.queue_free()

func load_player(player_node : Node2D):
	game_root.add_child(player_node)

func load_camera(camera_node : Node2D):
	game_root.add_child(camera_node)
