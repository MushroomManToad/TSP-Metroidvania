class_name Facing

# Used as facing direction (right = 0, left = 1) for the player and enemies who require it.
enum {
	RIGHT,
	LEFT
}

# Transform a direction (int) to the standard orientation (Right = 1, Left = -1)
# for scaling or movement. Returns zero on invalid input
static func transform(direction : int) -> int :
	if direction == RIGHT:
		return 1
	if direction == LEFT:
		return -1
	return 0
