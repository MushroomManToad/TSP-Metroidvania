class_name AbstractEnemy

extends CharacterBody2D

@export var brain : AbstractBrain
@export var max_hp : float

var current_hp : float

var current_i_frames : int = 0

@export var FACING : int = Facing.RIGHT
@export var sprite_for_facing : Node2D

func _ready() -> void:
	if FACING == Facing.LEFT:
		turn()
	_sub_ready()

func _physics_process(delta: float) -> void:
	# Decrease iframes per frame
	current_i_frames = max(0, current_i_frames - 1)
	# Handle subclass physics process
	_sub_physics_process(delta)
	# Update brain behavior
	if brain != null:
		brain.do_brain_logic(delta)

## CALL FOR _READY() BEHAVIOR IN SUBCLASS
func _sub_ready() -> void:
	pass

## CALL TO DO PHYSICS PROCESSING IN SUBCLASS
func _sub_physics_process(delta : float) -> void:
	pass

# Function called by player attack box when it hits this enemy
func on_attacked(player_attack_box : PlayerAttackBox):
	## TODO: Can throw in some armor logic here if that's ever relevant
	damage(player_attack_box.get_attack_damage())
	pass

## Returns true if damage actually applied
func damage(amount : float) -> bool:
	return damage_i_frame_override(amount, base_i_frames())

## Returns true if damage actually applied
func damage_i_frame_override(amount : float, i_frames : int) -> bool:
	var has_i_frames : bool = (current_i_frames > 0)
	if not has_i_frames:
		set_i_frames(i_frames)
		current_hp -= amount
		if current_hp <= 0.0:
			die()
	return has_i_frames

func die():
	## TODO: Play Death Animation
	queue_free()
	## TODO: Drop "currency"
	pass

func turn():
	if FACING == Facing.RIGHT:
		FACING = Facing.LEFT
		sprite_for_facing.scale.x = -1
	else:
		FACING = Facing.RIGHT
		sprite_for_facing.scale.x = 1

# Called when an attack is parried (handled via signal)
func on_parried():
	print_debug("Warning: Enemy", self.name, "has no behavior on being parried.")
	pass

func base_i_frames() -> int:
	return 10

func set_i_frames(amount : int) -> void:
	current_i_frames = amount
