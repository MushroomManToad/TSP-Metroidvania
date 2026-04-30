extends Area2D

func _ready() -> void:
	collision_layer = CollisionDict.POGOABLE_BOX.get_layer()
	collision_mask = CollisionDict.POGOABLE_BOX.get_mask()
