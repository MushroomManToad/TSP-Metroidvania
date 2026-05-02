class_name SettingsTabButtonContainer

extends MarginContainer

@export var buttons_registry : Array[SettingsSceneTabButton]

func depress_all() -> void:
	for b in buttons_registry:
		b.set_pressed_no_signal(false)
		b.button_mask = 1
		if b.node_to_enable:
			b.node_to_enable.visible = false
			b.node_to_enable.process_mode = Node.PROCESS_MODE_DISABLED
