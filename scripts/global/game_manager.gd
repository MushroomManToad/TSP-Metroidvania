extends Node

## Global GameManager Sub-Systems
var GameSettings : Game_Settings
var LanguageDirectory : Language_Directory
var LevelManager : Level_Manager

## Game State Tracker
var game_state : int = GameStates.STATES.IN_GAME

## Instantiable Variables
const PAUSE_SCREEN = preload("res://scenes/ui/pause_screen.tscn")


func _ready() -> void:
	# Disable Pausible State Immediately -- we never want this node to be paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _delayed_ready():
	# Initiate each of the sub-system variables (we do this here to prevent
	# pre-load memory errors)
	# Additionally, run each of their ready functions in order
	GameSettings = Game_Settings.new()
	GameSettings.on_ready()
	LanguageDirectory = Language_Directory.new()
	LanguageDirectory.on_ready()
	LevelManager = Level_Manager.new()
	LevelManager.on_ready()

var frames_elapsed = 0
## Physics loop on the global static class. Don't use this for much.
func _physics_process(_delta: float) -> void:
	# Delay subclass loading by a frame to ensure game setup runs appropriately
	if frames_elapsed == 1:
		_delayed_ready()
	frames_elapsed += 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		# Only run the pause check loop if we are in-game
		match game_state:
			GameStates.STATES.IN_GAME:
				if !get_tree().paused:
					# Set Pause State on Escape Pressed
					get_tree().paused = true
					# Enable Pause Screen
					get_tree().root.add_child(PAUSE_SCREEN.instantiate())
					# Consume input (saves processing this frame)
					get_viewport().set_input_as_handled()
