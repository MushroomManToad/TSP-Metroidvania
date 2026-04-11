class_name PlayerCamera

extends Node2D

var target : PlayerController
var player_direction_offset : int = 25
var player_sprint_direction_offset : int = 40
var player_height_offset : int = 24

# Time (sec) of a target_pos TWEEN. Solved by vibes.
var transition_duration : float = 0.75

var soft_position : Vector2
@export var speed : float = 3.
@onready var camera_anchor: Node2D = $".."

@onready var cam: Camera2D = $PlayerCamera

var hard_limits: LimitRect

func _ready() -> void:
	if target:
		global_position = target.global_position
	soft_position = global_position

## Used for debug when collision shapes are shown, also shows the camera details.
func _draw():
	if not get_tree().debug_collisions_hint:
		return
	draw_arc(Vector2.ZERO, player_direction_offset, 0, TAU, 64, Color.WEB_PURPLE, 2.0)
	draw_arc(cam.position, 5, 0, TAU, 64, Color.PURPLE, 1.0)

var target_pos_tween
var current_target_pos : Vector2 = Vector2(0, 0)
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
	target_pos_tween.tween_property(cam, "position", target_pos, transition_duration)
	# Set this variable to track when there is a new target aimed for (since this is inaccessible from Tween)
	current_target_pos = target_pos
	# Ensures the tweened pos cannot take us beyond hard limits with a second call after the first.
	target_pos_tween.connect("finished", snap_to_limits)

func _process(delta: float) -> void:
	if get_tree().debug_collisions_hint:
		queue_redraw()
	if target:
		# Initially, center camera target (i.e. (0, 0) offset
		var target_pos = Vector2(0., 0.)
		# Compute offset by looking direction if looking
		var look_distance : int = GameManager.GAME_SIZE.y - player_height_offset * 2
		if target.look_up_timer > target.LOOK_TIMER_MIN:
			target_pos -= Vector2(0, 1) * look_distance
		if target.look_down_timer > target.LOOK_TIMER_MIN:
			target_pos += Vector2(0, 1) * look_distance
		# Then, offset it by where they're facing
		target_pos += Facing.transform(target.facing) * Vector2(player_direction_offset, 0)
		if target_pos != current_target_pos:
			animate(target_pos)
		
		# Finally, snap this whole thing inside camera boundaries if it's beyond them.
		snap_to_limits()

func snap_to_limits() -> Vector2:
	var cam_anchor_center : Vector2 = target.global_position
	# Move slightly up to center on the player, rather than on their feet
	cam_anchor_center -= Vector2(0, player_height_offset)
	if hard_limits:
		# TOP
		var cam_y_top = cam_anchor_center.y + cam.position.y - GameManager.GAME_SIZE.y / 2.
		if cam_y_top < hard_limits.limit_top:
			cam_anchor_center.y = hard_limits.limit_top + GameManager.GAME_SIZE.y / 2. - cam.position.y
		# BOT
		var cam_y_bot = cam_anchor_center.y + cam.position.y + GameManager.GAME_SIZE.y / 2.
		if cam_y_bot > hard_limits.limit_bot:
			cam_anchor_center.y = hard_limits.limit_bot - GameManager.GAME_SIZE.y / 2. - cam.position.y
		# LEFT
		var cam_x_left = cam_anchor_center.x + cam.position.x - GameManager.GAME_SIZE.x / 2.
		if cam_x_left < hard_limits.limit_left:
			cam_anchor_center.x = hard_limits.limit_left + GameManager.GAME_SIZE.x / 2. - cam.position.x
		# RIGHT
		var cam_x_right = cam_anchor_center.x + cam.position.x + GameManager.GAME_SIZE.x / 2.
		if cam_x_right > hard_limits.limit_right:
			cam_anchor_center.x = hard_limits.limit_right - GameManager.GAME_SIZE.x / 2. - cam.position.x
	global_position = cam_anchor_center
	#print(global_position)
	return cam_anchor_center

class LimitRect:
	var limit_top : int = -1000000
	var limit_bot : int = 1000000
	var limit_left : int = -1000000
	var limit_right : int = 1000000
	
	func _init(top, bot, left, right):
		limit_top = top
		limit_bot = bot
		limit_left = left
		limit_right = right
