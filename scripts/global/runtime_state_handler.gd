class_name Runtime_State_Handler

extends Node

## SET THIS VARIABLE TO AFFECT HOW THE GAME LAUNCHES
var run_mode : RunMode = RunMode.TITLE

## Game State Tracker
var game_state : int

var menu_scenes_by_id : Dictionary = {
	Menu.SETTINGS: "",
	Menu.TITLE: "scenes/ui/title/title_screen.tscn",
	Menu.FILE_SELECT: "scenes/ui/title/file_select_screen.tscn",
	Menu.CHARACTER_CREATOR: "scenes/ui/title/character_creator.tscn",
}

func _on_ready():
	match run_mode:
		RunMode.QUICKSTART_0:
			## TODO: Loads file 0
			pass
		RunMode.QUICKSTART:
			## TODO: Loads specified file
			pass
		RunMode.QUICKSTART_DEMO:
			## Loads demo_scene
			GameManager.LevelManager.load_scene("dev/demo_stage", Vector2(0.0, 26.0))
			game_state = GameStates.STATES.IN_GAME
		RunMode.TITLE:
			## Loads from Title Screen (DEFAULT. ALWAYS EXPORT WITH THIS.)
			load_screen_by_id(Menu.TITLE)
			game_state = GameStates.STATES.ON_MENU

func load_screen_by_id(id : Menu):
	if get_viewport():
		get_viewport().gui_release_focus()
	call_deferred("_load_screen_internal", id)

# Helper function for loading the title screen
func _load_screen_internal(id : Menu):
	GameManager.get_tree().change_scene_to_file(menu_scenes_by_id.get(id))

func load_save_game(file_number):
	game_state = GameStates.STATES.IN_GAME
	## TODO: Connection between the LevelManager and PersistentInventory
	# to load the correct file in the correct place with the correct data.
	
	# For now, just close the menu and load the demo scene.
	if get_viewport():
		get_viewport().gui_release_focus()
	GameManager.LevelManager.load_scene("dev/demo_stage", Vector2(0.0, 26.0))

enum RunMode {
	QUICKSTART_0,
	QUICKSTART_DEMO,
	QUICKSTART,
	TITLE,
}

enum Menu {
	SETTINGS,
	TITLE,
	FILE_SELECT,
	CHARACTER_CREATOR,
}
