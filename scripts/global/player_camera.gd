class_name PlayerCamera

extends Camera2D

var target : Node

func _process(delta: float) -> void:
	# Right now a simple lerp loop.
	# TODO: Make this good.
	if target != null:
		global_position = target.global_position 
