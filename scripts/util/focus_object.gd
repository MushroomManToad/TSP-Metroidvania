@tool
class_name FocusObject

extends Node2D

# Inner detection radius. If player is in this, this object has 100% of camera control.
# * (Unless sharing with another focus object)
@export var inner_radius: float = 16:
	set(value):
		inner_radius = maxf(0.0, value)
		queue_redraw()

# Outer detection radius. Goes from 0% to 100% control as player moves toward inner radius.
@export var outer_radius: float = 64:
	set(value):
		outer_radius = maxf(0.0, value)
		queue_redraw()

# Variables for the target look position (offset from self) and target camera zoom)
# The camera will lock to these values if the player is in the inner radius
@export var target_pos : Vector2
@export var target_zoom : float = 2.
# Percentage of the target positions achieved while inside the inner radius. Defaults to 1,
# But can be lowered for subtler effects
@export var max_percent : float = 1.0
 
# Circle Draw Variables
var draw_segments: int = 64
var inner_color: Color = Color(0.45, 0.215, 0.941, 0.8)
var outer_color: Color = Color(0.876, 0.691, 0.0, 0.8)
var line_width: float = 1.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		if GameManager.LevelManager.player_camera:
			GameManager.LevelManager.player_camera.add_focus_object(self)

func _draw() -> void:
	var should_draw: bool = false
 
	if Engine.is_editor_hint():
		# Always draw in the editor.
		should_draw = true
	else:
		# In-game: only draw when the "Visible Collision Shapes" option is on.
		should_draw = get_tree().debug_collisions_hint
 
	if not should_draw:
		return
 
	draw_arc(Vector2(0, 0), inner_radius, 0, TAU, draw_segments, inner_color, line_width)
	draw_arc(Vector2(0, 0), outer_radius, 0, TAU, draw_segments, outer_color, line_width)
