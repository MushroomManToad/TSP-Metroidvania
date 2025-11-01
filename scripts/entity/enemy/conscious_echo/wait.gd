extends AbstractBehavior

signal queue_idle

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	if is_first_frame:
		queue_idle.emit()
