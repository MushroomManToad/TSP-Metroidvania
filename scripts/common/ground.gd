extends TileMapLayer

func _ready() -> void:
	if tile_set:
		tile_set.set_physics_layer_collision_layer(0, CollisionDict.GROUND.layer)
		tile_set.set_physics_layer_collision_mask(0, CollisionDict.GROUND.mask)
