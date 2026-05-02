class_name SettingsSceneTabButton

extends TextureButton

@onready var tbc : SettingsTabButtonContainer = $"../.."
@export var node_to_enable : Node

func _on_tab_button_mouse_entered() -> void:
	if not button_pressed:
		grab_focus()

func _on_tab_button_mouse_exited() -> void:
	pass
	#if not button_pressed:
		#release_focus()

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		tbc.depress_all()
		button_mask = 0
		set_pressed_no_signal(true)
		# Load tab
		if node_to_enable:
			node_to_enable.visible = true
			node_to_enable.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		set_pressed_no_signal(true)
