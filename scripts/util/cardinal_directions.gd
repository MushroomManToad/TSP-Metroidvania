class_name CardinalDirections

enum {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

## Returns the vector corresponding to the axis of the direction provided
static func get_vector_from_direction(direction : int) -> Vector2:
	match direction:
		UP:
			return Vector2(0.0, -1.0)
		DOWN:
			return Vector2(0.0, 1.0)
		LEFT:
			return Vector2(-1.0, 0.0)
		RIGHT:
			return Vector2(1.0, 0.0)
	return Vector2(0.0, 0.0)
