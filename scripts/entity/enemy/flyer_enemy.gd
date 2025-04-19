extends AbstractEnemy

var internal_velocity : Vector2 = Vector2(0.0, 0.0)

var knockback_amount : Vector2 = Vector2(500.0, 500.0)

func _physics_process(delta: float) -> void:
	# Perma-heal the flyer
	current_hp = max_hp
	# Knockback!
	if internal_velocity.length_squared() > 0.0:
		internal_velocity /= 1.2
		if internal_velocity.length_squared() < 1.0:
			internal_velocity = Vector2(0.0, 0.0)
		velocity = internal_velocity
	move_and_slide()

func on_attacked(player_attack_box : PlayerAttackBox):
	super.on_attacked(player_attack_box)
	internal_velocity = knockback_amount * CardinalDirections.get_vector_from_direction(player_attack_box.get_attack_direction())


func _on_hurtbox_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass
