extends AbstractBehaviorCondition

@export var floor_colliding_body : CharacterBody2D

func _should_run():
	return floor_colliding_body.is_on_floor()
