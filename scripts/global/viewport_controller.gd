class_name ViewportController

extends SubViewportContainer

var BIG_SCALE : Vector2 = Vector2(1280.0, 720.0)
var SMALL_SCALE : Vector2 = Vector2(640.0, 360.0)
var DEFAULT_SCALE : float = 2.0

func _ready() -> void:
	sync_pos_to_scale()

func _process(delta: float) -> void:
	sync_pos_to_scale()

func sync_pos_to_scale():
	global_position = (scale * -SMALL_SCALE) + SMALL_SCALE
