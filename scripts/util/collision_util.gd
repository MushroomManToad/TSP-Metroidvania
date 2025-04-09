class_name CollisionUtility

static func is_on_layer(layer_map : int, layer : int) -> bool:
	return layer_map & (pow(2, layer - 1) as int)

enum Layers {
	NONE,
	DEFAULT,
	PLAYER_COLLISION,
	PLAYER_HURT,
	PLAYER_ATTACK,
	PLAYER_PARRY,
	ENEMY_COLLISION,
	ENEMY_HURT,
	ENEMY_ATTACK_PARRYABLE,
	ENEMY_ATTACK_NON_PARRYABLE,
	ENEMY_PARRY,
	GROUND,
	DECORATION,
	INTERACTABLE_AREA,
	DYNAMIC_COLLISION_BOX
}

enum AttackType {
	GROUND,
	AIR,
	WATER,
	NONE
}
