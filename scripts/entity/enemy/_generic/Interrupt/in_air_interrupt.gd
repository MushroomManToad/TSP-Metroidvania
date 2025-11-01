extends AbstractBehaviorInterrupt

@export var character_body_2d : CharacterBody2D

func _should_interrupt() -> bool:
	return not character_body_2d.is_on_floor()
