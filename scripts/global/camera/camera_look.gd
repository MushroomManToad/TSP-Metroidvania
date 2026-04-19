class_name CameraLook

extends Node2D


# Variables used for camera up-tilt and down-tilt
var LOOK_TIMER_MIN = 60
var look_up_timer : int = 0
var look_down_timer : int = 0

# Number of pixels away from 1/2 screen height to look
var look_screen_inset = 64

# Helper function to reset look vars when no longer looking
func reset_look_timers():
	look_up_timer = 0
	look_down_timer = 0

## Helper method to compute look timers
func handle_player_look(target : PlayerController) -> void:
	# Handle look up and down walking. Should only move camera while stationary
	if target.vel_walking == Vector2(0, 0) and target.vel_launch == Vector2(0, 0) \
		# Should only move camera while not attacking or parrying or dashing.
		and not target.is_attacking() and not target.is_parrying() \
		and not target.is_dashing() and target.is_on_floor():
		# Up
		if target.up_held:
			look_up_timer += 1
		else:
			look_up_timer = 0
		# Down
		if target.down_held:
			look_down_timer += 1
		else:
			look_down_timer = 0
	else:
		# Otherwise reset look timers
		reset_look_timers()
	# Quick check to ensure we only look one way at once.
	if look_up_timer > 0 and look_down_timer > 0:
		# Prioritize whichever input has been held longer, reset the other timer.
		if look_up_timer > look_down_timer:
			look_down_timer = 0
		else:
			look_up_timer = 0

## Returns -1 if looking up, 1 if looking down, 0 if not looking
func get_look_direction() -> int:
	if look_up_timer >= LOOK_TIMER_MIN:
		return -1
	elif look_down_timer >= LOOK_TIMER_MIN:
		return 1
	else:
		return 0

## Function called externally for camera position. Returns the resulting camera position
func get_look_vector(target : PlayerController, current_position : Vector2, delta : float, cam : PlayerCamera) -> Vector2:
	# First, compute look timers
	handle_player_look(target)
	# Next, based on those timers, get the look direction and set target_pos accordingly
	var target_pos = Vector2(0, 0)
	match get_look_direction():
		-1:
			target_pos = Vector2(0, (- GameManager.GAME_SIZE.y / 2) + look_screen_inset)
		1:
			target_pos = Vector2(0, (GameManager.GAME_SIZE.y / 2) - look_screen_inset)
	# Now, if target_pos is non-zero, clamp it to player, then extended screen edges
	if target_pos != Vector2(0, 0):
		target_pos = clamp_to_player_pos(target, current_position, target_pos, cam)
		target_pos = snap_to_edges_extended(current_position, target_pos, cam)
	# Finally, re-run the tween if this is a new target position
	if target_pos != current_target_pos:
		animate(target_pos)
	# And step the tween
	if target_pos_tween:
		target_pos_tween.custom_step(delta)
	return current_position + current_look_pos

func clamp_to_player_pos(target : PlayerController, current_pos : Vector2, target_pos : Vector2, cam : PlayerCamera) -> Vector2:
	var ret_val : Vector2 = current_pos + target_pos
	# DOWN
	if get_look_direction() > 0:
		ret_val.y = min(ret_val.y, target.global_position.y - cam.player_height_offset * 2. + GameManager.GAME_SIZE.y / 2.)
	# UP
	else:
		ret_val.y = max(ret_val.y, target.global_position.y - GameManager.GAME_SIZE.y / 2.)
	return ret_val - current_pos

# Same as snap function in base, but with extended limits
func snap_to_edges_extended(current_position : Vector2, target_pos : Vector2, cam : PlayerCamera) -> Vector2:
	var def_scale = GameManager.GAME.main_viewport.DEFAULT_SCALE
	var curr_scale = GameManager.GAME.main_viewport.curr_scale
	
	var result_pos = current_position + target_pos
	# TODO: docs
	var y_bot = cam.hard_limits.limit_bot + 16 - ((GameManager.GAME_SIZE.y * def_scale) / (2. * curr_scale))
	var y_top = cam.hard_limits.limit_top - 16 + ((GameManager.GAME_SIZE.y * def_scale) / (2. * curr_scale))
	
	var x_left = cam.hard_limits.limit_left + ((GameManager.GAME_SIZE.x * def_scale) / (2. * curr_scale))
	var x_right = cam.hard_limits.limit_right - ((GameManager.GAME_SIZE.x * def_scale) / (2. * curr_scale))

	result_pos.y = clamp(result_pos.y, y_top, y_bot)
	result_pos.x = clamp(result_pos.x, x_left, x_right)
	
	# Computs the offset between the initial result_pos and the clamped one
	var offset = (current_position + target_pos) - result_pos
	# Then apply that offset to the returned target_pos 
	# (since we DONT care about current position here - Tween handles that)
	return target_pos - offset



############################## TWEEN METHODS ##############################
var transition_duration = 0.5

var target_pos_tween : Tween
var current_target_pos : Vector2 = Vector2(0, 0)
var current_look_pos : Vector2 = Vector2(0, 0)
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
	target_pos_tween.tween_property(self, "current_look_pos", target_pos, transition_duration)
	# Set this variable to track when there is a new target aimed for (since this is inaccessible from Tween)
	current_target_pos = target_pos
	# Pause the tween for manual control
	target_pos_tween.pause()
