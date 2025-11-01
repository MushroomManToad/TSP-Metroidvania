class_name AbstractAnimator

extends Node2D

# Import Variables
@export var anim_player : AnimationPlayer

## Current state in the machine (set in ready for default state)
var current_state : AnimState
# Dictionary containing all available states mapped to names (setup in _ready())
# Names used should be the same as in AnimationPlayer
var animation_states : Dictionary

# Dictionary of usable flags in this state
var flags := {}

func register_states():
	push_warning("Register states for ", self, " by overriding register_states().")
	#animation_states.get_or_add(PLAYER_IDLE, \
		#AnimState.new([
				#AnimState.Transition.new(
					#PLAYER_RUN, 
					#func() : return is_running)
		#]))

func get_default_state() -> String:
	push_error("No default state for animator ", self, ". This isn't going to work well!")
	return ""

func read_in_state() -> void:
	push_error("No state read in for ", self)

func post_process() -> void:
	push_warning("Should override post_process in ", self, " even if unused.")

func _ready() -> void:
	register_states()
	set_state_by_name(get_default_state())

func _process(_delta: float) -> void:
	read_in_state()
	update_animation()
	post_process()

## Updates current state when transition conditions are met (up to 10 per frame)
# We cap it at 10 to ensure there's no while loop crashes, but print an error
# if 10 transitions is ever hit, as that's likely an oversight in transition
# parameters
func update_animation() -> void:
	var update_count : int = 0
	while current_state.next_state() != "" and update_count < 10:
		update_count += 1
		set_state_by_name(current_state.next_state())
		for f in current_state.flags:
			flags[f].consume()
	if update_count >= 10:
		push_error("ERROR: Too many animation updates attempted in ", self)

func play_animation(anim_name : String):
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func set_state_by_name(state_name : String):
	current_state = animation_states.get(state_name)
	anim_player.play(state_name)

class AnimationFlag:
	var active : bool = false
	
	func set_active() -> void:
		active = true
	
	func consume() -> bool:
		if active:
			active = false
			return true
		return false
