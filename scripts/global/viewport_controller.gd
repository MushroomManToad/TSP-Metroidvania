class_name ViewportController

extends SubViewportContainer

var BIG_SCALE : Vector2 = Vector2(1280.0, 720.0)
var SMALL_SCALE : Vector2 = Vector2(640.0, 360.0)
var DEFAULT_SCALE : float = 2.0
var curr_scale : float = 2.0

func _ready() -> void:
	curr_scale = DEFAULT_SCALE
	sync_pos_to_scale()

func rescale(new_scale : float) -> void:
	scale = Vector2(new_scale, new_scale)
	curr_scale = new_scale
	sync_pos_to_scale()

func sync_pos_to_scale():
	global_position = (scale * -SMALL_SCALE) + SMALL_SCALE
