class_name IInteractable

## Area2D is the area in which the player must be to interact
extends Area2D

func _ready() -> void:
	# Used to connect the body_entered signal (which we know exists by type) to
	# the corresponding method
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	on_ready()

func on_interact() -> void:
	assert(false, "Please override `on_interact()` in the derived script.")

func on_ready() -> void:
	assert(false, "Please override `on_ready()` in the derived script.")

# Override to give a higher/lower priority to this type of interactable.
# Default 0.
func get_interact_priority() -> int:
	return 0

func _on_area_entered(area : Node2D):
	if area is PlayerInteractBox:
		area.add_interactable_object(self)

func _on_area_exited(area : Node2D):
	if area is PlayerInteractBox:
		area.remove_interactable_object(self)
