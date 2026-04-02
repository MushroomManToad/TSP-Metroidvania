class_name PonyAnimationController

extends AnimationPlayer

var STATE : PonyAnimationState = PonyAnimationState.IDLE

signal jump_frame(val: int)
signal fall_frame(val: int)
signal land

const id_dict : Dictionary = {
	PonyAnimationState.IDLE: "pony_idle_standard",
	PonyAnimationState.WALK: "pony_walk_standard",
	PonyAnimationState.JUMP: "pony_jump_standard",
	PonyAnimationState.JUMP_PLAYER: "pony_jump_player_standard",
	PonyAnimationState.FALL: "pony_fall_standard",
	PonyAnimationState.LAND: "pony_land_animation",
}

signal on_base_anim_update

func _ready() -> void:
	on_base_anim_update.connect(_on_base_anim_update)

func _on_base_anim_update():
	speed_scale = 1.0

func play_anim(state : PonyAnimationState):
	if not STATE == state:
		STATE = state
		reset()
		play(id_dict.get(state))
		advance(0)
		on_base_anim_update.emit()

func play_anim_scaled(speed : float, state : PonyAnimationState):
	play_anim(state)
	speed_scale = speed

func reset():
	play("RESET")
	advance(0)

enum PonyAnimationState {
	IDLE,
	WALK,
	JUMP,
	JUMP_PLAYER,
	FALL,
	LAND,
}
