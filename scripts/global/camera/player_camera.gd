class_name PlayerCamera

extends Node2D

var target : PlayerController
# Roughly 1/2 player height for camera centering.
var player_height_offset : int = 24

# Hard Limits passed from camera boundaries on load
var hard_limits: LimitRect

# Child objects for reference
@onready var look: CameraLook = $Look
@onready var focus_object: CameraFollowFocusObject = $Look/FocusObject
@onready var left_right: CameraLeftRight = $Look/FocusObject/Left_Right
@onready var player_camera: CameraEdgeSnap = $Look/FocusObject/Left_Right/PlayerCamera

var fpa : Vector2 = Vector2(0.0, 0.0)

func _process(delta: float) -> void:
	## First, center on the player
	var current_position : Vector2 = center_on_player()
	## Also, set current zoom to the default rather than true current, 
	## Since this MUST reset every frame if nothing acts on it
	var current_scale : float = GameManager.GAME.main_viewport.DEFAULT_SCALE
	debug_cam_target_center = current_position
	## Then, take the adjustments from whether they're looking left or right
	current_position = left_right.get_left_right(target, current_position, delta)
	debug_cam_lr = current_position
	## Now, snap to edge to get a true position
	#current_position = snap_to_edge(current_position)
	# TODO: Debug
	## Next, get the pull of focus_objects
	var foo : CameraFollowFocusObject.FocusObjectOffsetHolder = \
			focus_object.get_focus_object_affect(target, current_position, current_scale, self)
	current_position = foo.pos
	current_scale = foo.zoom
	# TODO: Debug
	## Snap to edges again
	current_position = snap_to_edge(current_position)
	# TODO: Debug
	## Finally, get the look up/down offset (Includes extended edge snapping)
	current_position = look.get_look_vector(target, current_position, delta, self)
	# TODO: Debug

	# TODO: Debug
	
	## Finally, assign to global position
	# TODO: Maybe don't use look for this. I only do for debug 
	#fpa += current_position - look.global_position
	
	look.global_position = current_position #look.global_position + Vector2(int(fpa.x), int(fpa.y))
	
	#fpa = Vector2(fposmod(fpa.x, 1.0), fposmod(fpa.y, 1.0))
	## And assign to current zoom
	GameManager.GAME.main_viewport.rescale(current_scale)
	## DEBUG Draw Queue
	if get_tree().debug_collisions_hint:
		queue_redraw()

# Center on the player (add player height offset so it centers on player center)
func center_on_player() -> Vector2:
	if target:
		# Return the target's center (negative is up)
		return target.global_position - Vector2(0, player_height_offset)
	# Default to doing nothing
	return global_position

func snap_to_edge(current_position : Vector2) -> Vector2:
	# TODO: docs
	var def_scale = GameManager.GAME.main_viewport.DEFAULT_SCALE
	var curr_scale = GameManager.GAME.main_viewport.curr_scale
	
	var y_bot = hard_limits.limit_bot - ((GameManager.GAME_SIZE.y * def_scale) / (2. * curr_scale))
	var y_top = hard_limits.limit_top + ((GameManager.GAME_SIZE.y * def_scale) / (2. * curr_scale))
	
	var x_left = hard_limits.limit_left + ((GameManager.GAME_SIZE.x * def_scale) / (2. * curr_scale))
	var x_right = hard_limits.limit_right - ((GameManager.GAME_SIZE.x * def_scale) / (2. * curr_scale))
	
	var ret_val = current_position
	ret_val.y = clamp(ret_val.y, y_top, y_bot)
	ret_val.x = clamp(ret_val.x, x_left, x_right)
	return ret_val

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

func add_focus_object(fo : FocusObject):
	focus_object.add_focus_object(fo)

var debug_cam_target_center : Vector2
var debug_cam_lr : Vector2

## Used for debug when collision shapes are shown, also shows the camera details.
func _draw():
	if not get_tree().debug_collisions_hint:
		return
	# Debug player target pos
	draw_arc(debug_cam_target_center, 10, 0, TAU, 64, Color.WHITE, 1.0)
	draw_line(debug_cam_target_center - Vector2(15, 0), debug_cam_target_center + Vector2(15, 0), Color.WHITE, 1.0)
	draw_line(debug_cam_target_center - Vector2(0, 15), debug_cam_target_center + Vector2(0, 15), Color.WHITE, 1.0)
	
	draw_arc(debug_cam_lr, 5, 0, TAU, 64, Color.WEB_PURPLE, 1.0)
