class_name AnimationState

extends Node

# Var is true if L/R work in this state
@export var can_move : bool = true

var transitions : Array[Transition] = []

func _init(_transitions : Array[Transition] = []):
	self.transitions = _transitions

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
