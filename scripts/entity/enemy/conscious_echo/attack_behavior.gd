extends AbstractBehavior
## TODO: Interrupt on Parry
@export var enemy : ConsciousEchoEnemy

signal queue_attack

## Loops each frame to run the behavior. Override in behavior class.
func _process_behavior(delta : float) -> void:
	if is_first_frame:
		queue_attack.emit()
	if remaining_time <= 70 && remaining_time > 60:
		enemy.velocity.x = 40. * Facing.transform(enemy.FACING)
	elif remaining_time == 59:
		enemy.velocity.x = 0


func _end_behavior():
	enemy.velocity.x = 0
