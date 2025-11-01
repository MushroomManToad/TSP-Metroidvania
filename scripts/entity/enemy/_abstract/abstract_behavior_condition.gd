class_name AbstractBehaviorCondition

extends Node2D

## Override in subclass to determine if this behavior is valid this frame.
func _should_run() -> bool:
	return true
