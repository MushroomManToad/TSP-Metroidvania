## This is now more of a state machine. But the old name is kinda stuck here.
class_name PlayerSprite

extends Node2D

const PLAYER_IDLE : String = "player_idle"
const PLAYER_RUN : String = "player_run"

# Import Variables
@export var player : PlayerController
@export var sprite_main: AnimatedSprite2D
@export var anim_player : AnimationPlayer

## Current state in the machine (set in ready for default state)
var current_state : AnimationState
# Dictionary containing all available states mapped to names (setup in _ready())
# Names used should be the same as in AnimationPlayer
var animation_states : Dictionary

# State Tracking Variables
var is_running : bool = false

func register_states():
	animation_states.get_or_add(PLAYER_IDLE, \
		AnimationState.new([
				AnimationState.Transition.new(
					PLAYER_RUN, 
					func() : return is_running)
		]))
	animation_states.get_or_add(PLAYER_RUN, \
		AnimationState.new([
			AnimationState.Transition.new(
				PLAYER_IDLE, 
				func() : return not is_running)
		]))

func _ready() -> void:
	register_states()
	set_state_by_name(PLAYER_IDLE)

func _process(_delta: float) -> void:
	read_in_state()
	update_animation()

## Reads all relevant data from the player class and stores locally
func read_in_state() -> void:
	is_running = player.is_walking()

## Updates current state when transition conditions are met (up to 10 per frame)
# We cap it at 10 to ensure there's no while loop crashes, but print an error
# if 10 transitions is ever hit, as that's likely an oversight in transition
# parameters
func update_animation() -> void:
	var update_count : int = 0
	while current_state.next_state() != "" and update_count < 10:
		update_count += 1
		set_state_by_name(current_state.next_state())
	if update_count >= 10:
		push_error("ERROR: Too many animation updates attempted in PlayerSprite")

func play_animation(anim_name : String):
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

func set_state_by_name(state_name : String):
	current_state = animation_states.get(state_name)
	anim_player.play(state_name)

func can_current_state_move() -> bool:
	return current_state.can_move
