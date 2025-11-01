extends AbstractBehavior

@export var enemy : ConsciousEchoEnemy
@export var animated_sprite_2d : AnimatedSprite2D

signal queue_walk

var step_queued : bool = false
var step_dequeued : bool = false
var queued_val : int = 0

func enqueue_step(val : int):
	step_queued = true
	queued_val = val

## Override to do special behavior when the Behavior is started.
func _start_behavior() -> void:
	step_queued = false
	step_dequeued = false
	queued_val = 0

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	if is_first_frame:
		queue_walk.emit()
	if step_queued:
		if step_dequeued:
			animated_sprite_2d.play("Walking" + str(queued_val), 1.0, false)
			step_dequeued = false
			step_queued = false
			queued_val = 0
			enemy.velocity.x = 0.
		else:
			step_dequeued = true
			enemy.velocity.x = 120. * Facing.transform(enemy.FACING)
