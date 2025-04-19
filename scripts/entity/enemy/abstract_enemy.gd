class_name AbstractEnemy

extends CharacterBody2D

@export var max_hp : float

var current_hp : float

# Function called by player attack box when it hits this enemy
func on_attacked(player_attack_box : PlayerAttackBox):
	## TODO: Can throw in some armor logic here if that's ever relevant
	damage(player_attack_box.get_attack_damage())
	pass

func damage(amount : float):
	current_hp -= amount
	if current_hp <= 0.0:
		die()

func die():
	## TODO: Play Death Animation
	queue_free()
	## TODO: Drop "currency"
	pass
