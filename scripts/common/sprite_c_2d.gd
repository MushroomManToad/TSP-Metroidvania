## Sprite class to be used by everything rendered in WorldSpace.
class_name SpriteC2D

extends Sprite2D

var base_pos: Vector2 = Vector2.ZERO  # replaces position, set this instead

func _ready() -> void:
	base_pos = position

func _process(delta):
	var world_pos = global_position - base_pos  # approximate world pos of the sprite origin
	var relative = world_pos - GameManager.LevelManager.player_camera.global_position
	var snap_correction = relative.round() - relative
	position = base_pos + snap_correction
	
	
