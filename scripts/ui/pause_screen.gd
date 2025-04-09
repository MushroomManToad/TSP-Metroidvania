extends CanvasLayer

@onready var resume: Button = $PauseContainer/MarginContainer/MarginContainer/VBoxContainer/Resume

func _ready() -> void:
	# Set focus to the first menu option on loading the pause screen
	# so that "scrolling" knows where to move focus later
	resume.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	## Input capture to close pause screen and unpause the game while paused
	if event.is_action_pressed("Pause") or event.is_action_pressed("Back"):
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

## Button actions

func _on_resume_pressed() -> void:
	unpause_from_pause_screen()
	
func _on_reload_scene_pressed() -> void:
	unpause_from_pause_screen()
	## TODO: Make sure this logic works once level loading is in
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	# Exit the game. Eventually exit to menu when that has meaning.
	get_tree().quit()
