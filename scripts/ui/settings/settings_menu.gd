class_name SettingsScreen

extends CanvasLayer

@onready var audio_tab_button: SettingsSceneTabButton = $"Root (Screen)/BG/TabButtonsContainer/HBoxContainer/AudioTabButton"

@export var back_button : Button

func _ready() -> void:
	audio_tab_button.grab_focus()
	audio_tab_button._on_toggled(true)

func on_ui_exit() -> void:
	queue_free()
