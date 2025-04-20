class_name PlayerHurtbox

extends Area2D

@export var player : PlayerController

signal take_damage(amount : int, ignores_i_frames : bool)
