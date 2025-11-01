class_name AbstractBehavior

extends Node2D

## Add a list of conditions that must be met to run this behavior
@export var conditions : Array[AbstractBehaviorCondition]
## Add a list of interrupts that can early cancel this behavior
@export var interrupts : Array[AbstractBehaviorInterrupt]

@export var default_max_timer : int
var remaining_time : int

var is_first_frame : bool = false

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	pass

## Override to do special behavior when the Behavior is started.
func _start_behavior() -> void:
	pass

## Override to do special behavior when this Behavior is interrupted.
func _end_behavior() -> void:
	pass

## Check if this behavior is valid in the current state
# i.e. all conditions are met.
func can_behavior_run() -> bool:
	# Iterate through all conditions and ensure they're met (true)
	for con in conditions:
		if not con._should_run():
			return false
	return true

## Check if this behavior should interrupt this frame.
# i.e. ANY interrupt condition is met.
func should_interrupt() -> bool:
	# Iterate through all interrputs and ensure they're not met (false)
	for intr in interrupts:
		if intr._should_interrupt():
			return true
	return false
