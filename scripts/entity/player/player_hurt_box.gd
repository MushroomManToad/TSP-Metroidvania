class_name PlayerHurtbox

extends Area2D

@export var player : PlayerController

@warning_ignore_start("unused_signal")
signal take_damage(amount : int, ignores_i_frames : bool)
@warning_ignore_restore("unused_signal")
