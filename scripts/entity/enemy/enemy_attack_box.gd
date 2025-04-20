class_name EnemyAttackBox

extends Area2D

@export var is_parryable : bool
@export var is_hazard_respawn : bool
@export var does_hitstun : bool = true
@export var damage_amount : int = 1
@export var ignores_i_frames : bool = false

# Current attack direction (used for knockback and parries) (CardinalDirections)
var attack_direction : int

signal on_parried

func on_attack_parried() -> void:
	# Emit the parried signal so that the entity 
	# can run any relevant code of its own
	on_parried.emit()
	# Destroy this object
	queue_free()

## Call to setup box on instantiation
# enemy is of type AbstractEnemy, and direction is of type CardinalDirection
func setup_box(enemy : AbstractEnemy, direction : int):
	if is_parryable:
		enemy.connect("on_parried", enemy.on_parried())
	attack_direction

## Collision code
func _on_area_entered(area: Area2D) -> void:
	# First, ensure we've hit a PlayerHurtbox 
	# (should always be the case, but this doubles as a cast)
	if area is PlayerHurtbox:
		# If attack box is parryable and player is parrying AND is parrying in
		# the right direction.
		if is_parryable \
		and area.player.is_parrying() \
		and is_correct_parry_direction(area.player.parry_direction):
			# Player side of the parry
			area.player.on_successful_parry()
			# This object side of the parry
			on_attack_parried()
		# Otherwise it's just doing damage!
		else:
			# Deal the damage_amount to the player, 
			# ignoring i_frames if it's a hazard respawn or otherwise ignores i_frames
			area.take_damage.emit(damage_amount, ignores_i_frames or is_hazard_respawn)

# Check if the player is parrying in the correct direction to absorb this attack
# direction is of type ParryDirections
# Returns true for non-up/down attacks if parry is not NONE
func is_correct_parry_direction(direction : int) -> bool:
	if direction == ParryDirections.OMNI:
		return true
	match attack_direction:
		CardinalDirections.LEFT:
			return direction == ParryDirections.RIGHT or direction == ParryDirections.OMNI
		CardinalDirections.RIGHT:
			return direction == ParryDirections.LEFT or direction == ParryDirections.OMNI
		_:
			return direction != ParryDirections.NONE
