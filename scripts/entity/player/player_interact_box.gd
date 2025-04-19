class_name PlayerInteractBox

extends Area2D

var interactable_objects = []

## Function called on up button pressed.
func on_interacts():
	## TODO: can_interact logic to freeze out potential further interactions
	# If there are any objects with which to interact, interact with the first
	# available (i.e. the one longest in interaction range)
	if interactable_objects.size() > 0:
		get_highest_priority_interactable().on_interact()

func get_highest_priority_interactable() -> IInteractable:
	var best : IInteractable
	var best_priority : int = -INF
	
	for obj in interactable_objects:
		var interactable : IInteractable = obj as IInteractable
		var prio : int = interactable.get_interact_priority()
		
		if prio > best_priority:
			best = interactable
			best_priority = prio
	
	return best

## Collisions for the following two methods are handled by the IInteractables.
func add_interactable_object(obj : IInteractable):
	interactable_objects.append(obj)

func remove_interactable_object(obj : IInteractable):
	interactable_objects.erase(obj)
