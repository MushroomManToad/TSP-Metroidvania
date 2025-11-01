class_name AnimState

extends Node

# Var is true if L/R work in this state
@export var can_move : bool = true

var transitions : Array[Transition] = []
var flags : Array[String] = []

## Includes a list of transitions and a list of flags, where flags are overwritten
## on this behavior being selected.
func _init(_flags : Array[String] = [], _transitions : Array[Transition] = []):
	self.transitions = _transitions
	self.flags = _flags

func next_state() -> String:
	for transition in transitions:
		if transition.condition.call():
			return transition.target_state
	return ""

class Transition:
	var target_state : String
	var condition : Callable
	
	func _init(target_state_name : String, _condition : Callable) -> void:
		self.target_state = target_state_name
		self.condition = _condition
