class_name IInteractable

## Area2D is the area in which the player must be to interact
extends Area2D

func _ready() -> void:
	# Used to connect the body_entered signal (which we know exists by type) to
	# the corresponding method
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	on_ready()

func on_interact() -> void:
	assert(false, "Please override `on_interact()` in the derived script.")

func on_ready() -> void:
	assert(false, "Please override `on_ready()` in the derived script.")

func _on_body_entered(body : Node2D):
	if body is PlayerController:
		body.add_interactable_object(self)

func _on_body_exited(body : Node2D):
	if body is PlayerController:
		body.remove_interactable_object(self)
