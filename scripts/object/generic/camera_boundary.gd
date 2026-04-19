@tool
extends Node2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		if GameManager.LevelManager.player_camera:
			apply_to_camera(GameManager.LevelManager.player_camera)

## The boundary rect, in this node's local space
@export var boundary_rect: Rect2 = Rect2(-320, -180, 640, 360):
	set(v): boundary_rect = v; queue_redraw()

@export var boundary_color: Color = Color(0, 0.3, 1.0, 0.85):
	set(v): boundary_color = v; queue_redraw()

@export var look_boundary_color: Color = Color(1.0, 0.1, 0.1, 0.85):
	set(v): look_boundary_color = v; queue_redraw()

@export var line_width: float = 2.0:
	set(v): line_width = v; queue_redraw()

## Show the boundary lines at runtime too (e.g. for debug builds)
@export var show_in_game: bool = false

func _draw() -> void:
	if not Engine.is_editor_hint() and not show_in_game:
		return
	var r := boundary_rect
	
	draw_rect(r, boundary_color, false, line_width)
	# Draw corner ticks for clarity
	_draw_corners(r, boundary_color)
	
	# Look Border Rect
	var r2 : Rect2 = r.grow(16)
	# Second Rect
	draw_rect(r2, look_boundary_color, false, line_width)
	# Draw corner ticks for clarity
	_draw_corners(r2, look_boundary_color)

func _draw_corners(r: Rect2, c : Color) -> void:
	var tick := 12.0
	var w := line_width + 1.0
	# Top-left
	draw_line(r.position, r.position + Vector2(tick, 0), c, w)
	draw_line(r.position, r.position + Vector2(0, tick), c, w)
	# Top-right
	var _tr := Vector2(r.end.x, r.position.y)
	draw_line(_tr, _tr + Vector2(-tick, 0), c, w)
	draw_line(_tr, _tr + Vector2(0,  tick), c, w)
	# Bottom-left
	var bl := Vector2(r.position.x, r.end.y)
	draw_line(bl, bl + Vector2( tick, 0), c, w)
	draw_line(bl, bl + Vector2(0, -tick), c, w)
	# Bottom-right
	draw_line(r.end, r.end + Vector2(-tick, 0), c, w)
	draw_line(r.end, r.end + Vector2(0, -tick), c, w)

## Call this from your camera setup code to apply limits automatically
func apply_to_camera(cam: PlayerCamera) -> void:
	var world_rect := Rect2(to_global(boundary_rect.position), boundary_rect.size)
	cam.hard_limits = PlayerCamera.LimitRect.new(
		int(world_rect.position.y),
		int(world_rect.end.y),
		int(world_rect.position.x),
		int(world_rect.end.x)
	)
