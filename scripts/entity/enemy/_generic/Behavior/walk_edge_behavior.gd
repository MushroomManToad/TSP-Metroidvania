extends AbstractBehavior

@export var character_body_2d : AbstractEnemy
@export var edge_detection : RayCast2D

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	character_body_2d.velocity.x = 8 * Facing.transform(character_body_2d.FACING)
	if edge_detection.get_collider() == null:
		character_body_2d.turn()

## Override to do special behavior when the Behavior is started.
func _start_behavior() -> void:
	# Add a lil time, or remove it, from the default second.
	remaining_time += randi_range(30, 210)

func _end_behavior() -> void:
	character_body_2d.velocity.x = 0
