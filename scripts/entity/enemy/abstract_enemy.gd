class_name AbstractEnemy

extends CharacterBody2D

@export var max_hp : float

# Function called by player attack box when it hits this enemy
func on_attacked(player_attack_box : PlayerAttackBox):
	pass
