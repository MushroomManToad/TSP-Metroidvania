class_name PlayerCamera

extends Camera2D

var target : Node

func _process(delta: float) -> void:
	# Right now a simple lerp loop.
	# TODO: Make this good.
	if target:
		# Smoothly move toward the target
		var target_pos = target.global_position
		global_position = global_position.lerp(target_pos, 5. * delta)
		
		# Round the position to snap to pixels
		#global_position = global_position.round()
