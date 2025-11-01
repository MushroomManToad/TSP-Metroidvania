extends AbstractBehavior

@export var enemy: ConsciousEchoEnemy

signal queue_turn

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	if is_first_frame:
		queue_turn.emit()
	
