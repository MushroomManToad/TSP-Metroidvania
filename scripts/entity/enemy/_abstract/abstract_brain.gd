class_name AbstractBrain

extends Node2D

@export var behaviors : Array[AbstractBehavior]
var active_behavior : AbstractBehavior

## Startup and default values
func _ready() -> void:
	# Load default behavior
	if behaviors.size() > 0:
		start_behavior(behaviors.back())
	else:
		push_warning("Brain ", self, " has no attached behaviors! This isn't going to work well!")

## Called each frame to update brain logic
func do_brain_logic(delta : float) -> void:
	# First, check for interrupts, and if so, set remaining time to 0 so behavior is overwritten this frame.
	if try_interrupt():
		active_behavior.remaining_time = 0
	# Choose new behavior if the old one has finished running
	if active_behavior.remaining_time <= 0:
		# First, end old behavior
		active_behavior._end_behavior()
		# Then choose new one
		choose_new_behavior()
	active_behavior._process_behavior(delta)
	active_behavior.remaining_time -= 1
	active_behavior.is_first_frame = false;

## Chooses a new behavior through the standard priority algorithm
func choose_new_behavior() -> AbstractBehavior:
	# Walk through behaviors in order
	for b in behaviors:
		# Try to start each behavior
		if try_start_behavior(b):
			## Start behavior
			start_behavior(b)
			return b
	## Should never be called, but in the worst case, default to the last behavior
	start_behavior(behaviors.back())
	return behaviors.back()

func try_start_behavior(b : AbstractBehavior) -> bool:
	## Internal behavior function that checks all conditions
	if b.can_behavior_run():
		# Returns true if all conditions passed
		return true
	# Else returns false
	return false

## Returns true if the active behavior should be interrupted
func try_interrupt() -> bool:
	return active_behavior.should_interrupt()

## Force starts a behavior
func start_behavior(b : AbstractBehavior) -> void:
	# start max timer
	b.remaining_time = b.default_max_timer
	# set it as the active behavior
	active_behavior = b
	b.is_first_frame = true
	# call its startup behavior
	b._start_behavior()
