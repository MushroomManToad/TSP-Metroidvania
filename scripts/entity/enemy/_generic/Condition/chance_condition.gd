extends AbstractBehaviorCondition

@export_range(0.0, 1.0) var chance : float = 0.5

func _should_run():
	return randf() <= chance
