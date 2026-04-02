extends TextureButton



func _on_mouse_entered() -> void:
	grab_focus()



func _on_mouse_exited() -> void:
	release_focus()
