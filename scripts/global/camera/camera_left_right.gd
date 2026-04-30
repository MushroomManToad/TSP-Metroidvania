class_name CameraLeftRight

extends Node2D

@onready var camera_anchor: PlayerCamera = $"../../.."

# How far ahead the camera looks while walking
var player_direction_offset : int = 20
# How far ahead the camera looks while sprinting
var player_sprint_direction_offset : int = 40

var current_lr_pos : Vector2 = Vector2(0, 0)

# Time (sec) of a target_pos TWEEN. Solved by vibes.
var transition_duration : float = 1.5

var target_pos_tween : Tween
var current_target_lr_pos : Vector2 = Vector2(0, 0)
# Creates a new Tween for the target pos whenever the targetted sub-position changes
func animate(target_pos : Vector2):
	# First, end the old Tween (leaves position where it was at end of last frame)
	if target_pos_tween:
		target_pos_tween.kill() # Abort the previous animation.
	# Define the new Tween with Quadradic In/Out easing to prevent jarring wiggle and easing at ends.
	target_pos_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Tween on the physics loop. Not... great for visuals, but prevents frame jitter.
	target_pos_tween.set_process_mode(0)
	# Start the transition on the correct property with duration
	target_pos_tween.tween_property(self, "current_lr_pos", target_pos, transition_duration)
	# Set this variable to track when there is a new target aimed for (since this is inaccessible from Tween)
	current_target_lr_pos = target_pos
	# Pause the tween for manual control
	target_pos_tween.pause()

func get_left_right(target : PlayerController, current_position : Vector2, delta : float) -> Vector2:
	var target_pos : Vector2 = Vector2(Facing.transform(target.facing) * Vector2(player_sprint_direction_offset if target.is_sprinting() else player_direction_offset, 0))
	if target_pos != current_target_lr_pos:
		animate(target_pos)
	# Step the tween when it exists
	# But do not step if the player is not moving to hide jitter.
	if target_pos_tween and abs(target.previous_frame_vel.x) > 0.0:
		target_pos_tween.custom_step(delta)
	return current_position + current_lr_pos
