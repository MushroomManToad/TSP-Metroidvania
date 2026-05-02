class_name CameraFallDrift

extends Node2D

@onready var camera_anchor: PlayerCamera = $"../../../.."

# How far down the camera should drift while falling
var player_direction_offset : int = 60

var current_drift_pos : Vector2 = Vector2(0, 0)

var activate_percent = 1.0

# Time (sec) of a target_pos TWEEN. Solved by vibes.
var down_duration : float = 1.0
var reset_duration : float = 1.0

var target_pos_tween : Tween
var current_target_drift_pos : Vector2 = Vector2(0, 0)
# Creates a new Tween for the target pos whenever the targetted sub-position changes
func animate(target_pos : Vector2, duration : float):
	# First, end the old Tween (leaves position where it was at end of last frame)
	if target_pos_tween:
		target_pos_tween.kill() # Abort the previous animation.
	# Define the new Tween with Quadradic In/Out easing to prevent jarring wiggle and easing at ends.
	target_pos_tween = create_tween().bind_node(self).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Tween on the physics loop. Not... great for visuals, but prevents frame jitter.
	target_pos_tween.set_process_mode(0)
	# Start the transition on the correct property with duration
	target_pos_tween.tween_property(self, "current_drift_pos", target_pos, duration)
	# Set this variable to track when there is a new target aimed for (since this is inaccessible from Tween)
	current_target_drift_pos = target_pos
	# Pause the tween for manual control
	target_pos_tween.pause()

func get_down_drift(target : PlayerController, current_position : Vector2, delta : float) -> Vector2:
	var target_pos : Vector2 = Vector2(0., 0.)
	# If the player is falling at at least 75% speed, start the drift
	if target.previous_frame_vel.y >= target.MAX_FALL_SPEED * activate_percent:
		target_pos = Vector2(0., player_direction_offset)
	if target_pos != current_target_drift_pos:
		animate(target_pos, reset_duration if target_pos == Vector2(0., 0.) else down_duration)
	# Step the tween when it exists
	if target_pos_tween :
		target_pos_tween.custom_step(delta)
	return current_position + current_drift_pos
