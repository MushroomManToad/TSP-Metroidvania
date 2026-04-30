@tool
extends Sprite2D

@export_category("Control Variables")
@export var direction : Directions

@export_category("Internal Variables")
@export var tile_size: Vector2 = Vector2(64, 64)
@export var default_world_size: Vector2 = Vector2(4, 4)  # 4x4 units at 16px/unit = 64px

var _last_scale: Vector2 = Vector2.ZERO
var _last_direction : Directions = Directions.UP

@onready var hazard_respawn_box: HazardRespawnBox = $HazardRespawnBox

enum Directions {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

func _process(_delta: float) -> void:
	if scale != _last_scale:
		resize_object()
	if _last_direction != direction:
		redirect_object()
	_last_scale = scale
	_last_direction = direction

func redirect_object():
	match direction:
		Directions.UP:
			rotation = 0.0
			if scale.x < 0.0:
				scale.x = abs(scale.x)
			if not Engine.is_editor_hint():
				hazard_respawn_box.set_direction(CardinalDirections.UP)
		Directions.DOWN:
			rotation = PI
			if scale.x > 0.0:
				scale.x = -scale.x
			if not Engine.is_editor_hint():
				hazard_respawn_box.set_direction(CardinalDirections.DOWN)
		Directions.LEFT:
			rotation = PI * 3. / 2.
			if scale.x > 0.0:
				scale.x = -scale.x
			if not Engine.is_editor_hint():
				hazard_respawn_box.set_direction(CardinalDirections.LEFT)
		Directions.RIGHT:
			rotation = PI / 2.
			if scale.x < 0.0:
				scale.x = abs(scale.x)
			if not Engine.is_editor_hint():
				hazard_respawn_box.set_direction(CardinalDirections.RIGHT)

func resize_object():
	# Snap scale so object size is always a whole number of pixels
	var snpd = Vector2(
		snapped(scale.x, 1.0 / (default_world_size.x * (16.0 / 2.0))),
		snapped(scale.y, 1.0 / (default_world_size.y * (16.0 / 2.0)))
	)
	scale = snpd
	
	# And scale the shader correctly
	var pixel_size = scale * default_world_size * 16.0
	material.set_shader_parameter("tile_repeat", pixel_size / tile_size)
	
	position = round(position)
