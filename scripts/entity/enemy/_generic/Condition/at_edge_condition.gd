extends AbstractBehaviorCondition

@export var raycast_2d : Node2D

## Override in subclass to determine if this behavior is valid this frame.
func _should_run() -> bool:
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(
		raycast_2d.global_position + Vector2(0, 0), 
		raycast_2d.global_position + Vector2(0, 1),
		0b00000000_00000000_00000100_00000000 # Ground layer collision
		)
	var result = space_state.intersect_ray(query)
	return result.is_empty()
