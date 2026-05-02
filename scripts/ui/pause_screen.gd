extends CanvasLayer

@onready var resume: Button = $PauseContainer/MarginContainer/MarginContainer/VBoxContainer/Resume
@onready var settings: Button = $PauseContainer/MarginContainer/MarginContainer/VBoxContainer/Settings
const SETTINGS_MENU = preload("uid://besklj6jbinm0")

# True if there is a lower order UI open
var is_secondary_ui : bool = false

signal close_settings

func _ready() -> void:
	# Set focus to the first menu option on loading the pause screen
	# so that "scrolling" knows where to move focus later
	resume.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	## Input capture to close pause screen and unpause the game while paused
	if event.is_action_pressed("Pause") or event.is_action_pressed("Back"):
		# Close the lower order menu and return to pause if open
		if is_secondary_ui:
			# Consume input (saves processing this frame)
			get_viewport().set_input_as_handled()
			regrab_focus()
		# Else resume the game.
		else:
			# Consume input (saves processing this frame)
			get_viewport().set_input_as_handled()
			# Unpause
			unpause_from_pause_screen()
	elif event.is_action_pressed("Select"):
		var active_obj = get_viewport().gui_get_focus_owner()
		if active_obj is Button:
			(active_obj as Button).emit_signal("pressed")
			get_viewport().set_input_as_handled()

## Generic function to unpause the game and close the pause screen.
func unpause_from_pause_screen() -> void:
	# Toggle Pause State on Escape Pressed
	get_tree().paused = false
	# Remove self from tree heirarchy
	queue_free()

## Function for regrabbing focus when a lower order menu closes
func regrab_focus():
	# Close the settings menu from its perspective
	close_settings.emit()
	# Regain focus on this screen to prevent issues (at button that opened menu)
	settings.grab_focus()
	# Ensure menu is visible again
	visible = true
	# Set flag
	is_secondary_ui = false

## Button actions

func _on_resume_pressed() -> void:
	if not is_secondary_ui:
		unpause_from_pause_screen()

# Open the settings menu
func _on_settings_pressed() -> void:
	if not is_secondary_ui:
		# Instantiate
		var settings_menu : SettingsScreen = SETTINGS_MENU.instantiate()
		# Connect the signal for remote closing without reference
		close_settings.connect(settings_menu.on_ui_exit)
		# And connect the signal for the exit button to return to this screen
		settings_menu.back_button.pressed.connect(regrab_focus)
		# Add to tree in its own layer (maybe moved to GUI layer later?)
		get_tree().root.add_child(settings_menu)
		# Hide pause screen in case of ordering issues
		visible = false
		# Set flag for other screen open
		is_secondary_ui = true

func _on_reload_scene_pressed() -> void:
	if not is_secondary_ui:
		unpause_from_pause_screen()
		# Reload the current scene from lingering variables stored in the Level Manager
		GameManager.LevelManager.load_scene(GameManager.LevelManager.prev_scene_name, GameManager.LevelManager.prev_player_spawn_pos)

func _on_exit_pressed() -> void:
	if not is_secondary_ui:
		# Exit the game. Eventually exit to menu when that has meaning.
		get_tree().quit()
