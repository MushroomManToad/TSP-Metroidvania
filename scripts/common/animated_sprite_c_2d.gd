class_name AnimatedSpriteC2D

extends AnimatedSprite2D

var base_pos: Vector2 = Vector2.ZERO  # replaces position, set this instead

func _ready() -> void:
	base_pos = position

func _process(delta):
	#var parent_world_pos = get_parent().global_position
	#var snap_correction = (parent_world_pos + base_pos).round() - (parent_world_pos + base_pos)
	#position = base_pos + snap_correction
	pass
	#print("global: ", global_position, " | intended: ", base_pos, " | parent_world_pos: ", parent_world_pos, " | correction: ", snap_correction)
