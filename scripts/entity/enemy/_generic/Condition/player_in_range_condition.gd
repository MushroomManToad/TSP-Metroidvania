extends AbstractBehaviorCondition

@export var enemy : AbstractEnemy
## Offsets defining a rectangle in which the player must be. Both coordinates here should be <= UR's
## Box only considers Player bottom center, so plan accordingly.
@export var lower_left_corner : Vector2
## Offsets defining a rectangle in which the player must be. Both coordinates here should be >= LL's
## Box only considers Player bottom center, so plan accordingly.
@export var upper_right_corner : Vector2

func _ready() -> void:
	if lower_left_corner.x > upper_right_corner.x || lower_left_corner.y < upper_right_corner.y:
		push_error("BOUNDING BOX FOR BEHAVIOR ", self, " IS INVALID")

func _should_run() -> bool:
	var player_pos = GameManager.LevelManager.player.global_position
	var rect_llc = lower_left_corner
	var rect_urc = upper_right_corner
	if enemy.FACING == Facing.LEFT:
		# Swap around box when enemy is facing the other way
		var lc = -rect_urc.x
		var uc = -rect_llc.x

		rect_llc.x = lc
		rect_urc.x = uc
	## Literally a bounding box test
	rect_llc += global_position
	rect_urc += global_position
	var ret : bool = \
		player_pos.x >= rect_llc.x && \
		player_pos.x <= rect_urc.x && \
		player_pos.y <= rect_llc.y && \
		player_pos.y >= rect_urc.y
	return ret
