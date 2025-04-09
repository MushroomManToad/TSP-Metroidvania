class_name PlayerAttackBox

extends Area2D

var attack_direction : int = CardinalDirections.RIGHT

@export var player : PlayerController
@onready var attack_collision_shape: CollisionShape2D = $AttackCollisionShape

## Player Knockbacks in various directions
var PK_LEFT_GROUND : Vector2 = Vector2(140.0, 0.0)
var PK_RIGHT_GROUND : Vector2 = Vector2(-140.0, 0.0)
var PK_UP_GROUND : Vector2 = Vector2(0.0, 70.0)
var PK_DOWN_GROUND : Vector2 = Vector2(0.0, -200.0)

var PK_LEFT_AIR : Vector2 = Vector2(140.0, -70.0)
var PK_RIGHT_AIR : Vector2 = Vector2(-140.0, -70.0)
var PK_UP_AIR : Vector2 = Vector2(0.0, 70.0)
var PK_DOWN_AIR : Vector2 = Vector2(0.0, -200.0)

# Variable used to track what has been hit so far
# Primarily used to ensure nothing is hit repeatedly.
var hit_list = []

## Function that handles all attack box effects on the player during collisions with bodies
# Effects on the body colliding should be handled locally in that body's collision code.
func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if not hit_list.has(body):
		## Knockback handler for body collisions.
		# Variable to store the bitmap for the colliding body's physics layers
		var body_collision_layer_map : int
		# Special case for tilemaps, since accessing their collision layers is a bit more complex
		if body is TileMapLayer:
			body_collision_layer_map = PhysicsServer2D.body_get_collision_layer(body_rid)
		# Standard case for all other physics bodies
		elif body is PhysicsBody2D:
			body_collision_layer_map = body.collision_layer
		# Ground Bonk
		if CollisionUtility.is_on_layer(body_collision_layer_map, CollisionUtility.Layers.GROUND):
			on_ground_hit()
		## TODO: For layers not the ground, cancel dash on attack landing
		
		hit_list.append(body)


## Function that handles all attack box effects on the player during collisions with areas
# Effects on the body colliding should be handled locally in that body's collision code.
func _on_area_shape_entered(body_rid: RID, body: Area2D, body_shape_index: int, local_shape_index: int) -> void:
	if not hit_list.has(body):
		# Shoutouts to Area2D for not needing several cases to get this value
		var body_collision_layer_map : int = body.collision_layer
		# Enemy Bonk
		if CollisionUtility.is_on_layer(body_collision_layer_map, CollisionUtility.Layers.ENEMY_HURT):
			on_enemy_hit(body)
		
		hit_list.append(body)

## Helper function for when an attack successfully lands on an enemy or enemy-like object (i.e. spikes)
func on_enemy_hit(body : Area2D) -> void:
	# The knockback
	player.enqueue_attack_launch(get_player_knockback_velocity_by_direction())
	
	# Cancel on going dashes and add another dash charge on attack landing
	if player.is_dashing():
		player.cancel_dash()
	player.charge_dash()
	# Refresh double jump
	player.charge_double_jump()
	
	# Run any logic from the enemy's side when it gets attacked
	# Should always be true, but this is a nice Godot cast
	if body is EnemyHitbox:
		body.get_enemy().on_attacked(self)

## Helper function for when an attack hits the ground
func on_ground_hit():
	# Handle launch vector
	# A little down on Up
	# A little back on horizontal
	# Nothing on down.
	var dir : Vector2 = get_player_knockback_velocity_by_direction()
	player.enqueue_attack_launch(Vector2(-dir.x * Facing.transform(player.facing), 0.0 if attack_direction == CardinalDirections.DOWN else dir.y))

func set_attack_direction(direction : int):
	attack_direction = direction

func get_attack_direction() -> int:
	return attack_direction

func get_player_knockback_velocity_by_direction() -> Vector2:
	# Var(s) to track which knockback type(s) should be used
	var in_air : bool = not player.is_on_floor()
	## ARIAL LAUNCH
	if in_air:
		match attack_direction:
			CardinalDirections.UP:
				# Cancel ongoing jumps
				player.cancel_jump()
				return PK_UP_AIR
			CardinalDirections.DOWN:
				return PK_DOWN_AIR
			CardinalDirections.LEFT:
				return PK_LEFT_AIR
			CardinalDirections.RIGHT:
				return PK_RIGHT_AIR
			_:
				return Vector2(0.0, 0.0)
	## GROUNDED LAUNCH
	else:
		match attack_direction:
			CardinalDirections.UP:
				return PK_UP_GROUND
			CardinalDirections.DOWN:
				return PK_DOWN_GROUND
			CardinalDirections.LEFT:
				return PK_LEFT_GROUND
			CardinalDirections.RIGHT:
				return PK_RIGHT_GROUND
			_:
				return Vector2(0, 0)

## Takes a CardinalDirection as direction and CollisionUtility.AttackType as attack type,
## then sets the corresponding variable to the passed Vec2
func set_player_knockback_from_attack(new_strength : Vector2, direction : int, attack_type : int) -> void:
	match attack_type:
		CollisionUtility.AttackType.AIR:
			match direction:
				CardinalDirections.UP:
					PK_UP_AIR = new_strength
				CardinalDirections.DOWN:
					PK_DOWN_AIR = new_strength
				CardinalDirections.LEFT:
					PK_LEFT_AIR = new_strength
				CardinalDirections.RIGHT:
					PK_RIGHT_AIR = new_strength
		CollisionUtility.AttackType.GROUND:
			match direction:
				CardinalDirections.UP:
					PK_UP_GROUND = new_strength
				CardinalDirections.DOWN:
					PK_DOWN_GROUND = new_strength
				CardinalDirections.LEFT:
					PK_LEFT_GROUND = new_strength
				CardinalDirections.RIGHT:
					PK_RIGHT_GROUND = new_strength
		_:
			print("ERROR: Invalid attack type ", attack_type, "passed for player.")

## Helper method for spawning an attack box. [br]
## Spawns the box and sets its direction.
func start_new_attack():
	# Update attack direction.
	set_attack_direction(player.attack_direction)
	# First, parameterize the position of the attack box by direction.
	# Yes, these are hard-coded. There are only four of them, and I'll have to
	# adjust them from somewhere, so why not here in the spawn function.
	var attack_bb = RectangleShape2D.new()
	match attack_direction:
		CardinalDirections.UP:
			attack_bb.size = Vector2(16, 14.5)
			attack_collision_shape.position = Vector2(0, -8.75)
		CardinalDirections.DOWN:
			attack_bb.size = Vector2(16, 14)
			attack_collision_shape.position = Vector2(0, 16)
		CardinalDirections.LEFT:
			attack_bb.size = Vector2(13, 17)
			attack_collision_shape.position = Vector2(-8.5, 2.5)
		CardinalDirections.RIGHT:
			attack_bb.size = Vector2(13, 17)
			attack_collision_shape.position = Vector2(8.5, 2.5)
	attack_collision_shape.shape = attack_bb
	# Clear out the old hit flags/list on the attack box
	hit_list.clear()
	# Finally, actually enable the attack box. 
	# Some of this isn't technically necessary, but helps with debugging.
	visible = true
	monitorable = true
	monitoring = true

## Helper method for ending an attack. Disables the attack box and collision.
func end_attack():
	monitorable = false
	monitoring = false
	visible = false
