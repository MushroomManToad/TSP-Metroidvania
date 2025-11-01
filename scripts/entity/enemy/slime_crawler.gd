extends AbstractEnemy

# Maximum fall velocity
const MAX_FALL_SPEED : float = 1000.0
# Gravity
const GRAVITY : float = 10.0



func _sub_physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY + (GRAVITY * 0.5 if velocity.y < 0 else 0.0)
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		velocity.y = 0.0
	# Update physics based on all physics data
	move_and_slide()
