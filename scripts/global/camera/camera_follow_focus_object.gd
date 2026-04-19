class_name CameraFollowFocusObject

extends Node2D

var active_focus_objects : Array[FocusObject] = []

func add_focus_object(fo : FocusObject):
	active_focus_objects.append(fo)

## Helper function that takes a Focus Object and returns its pull on the camera this frame
func get_single_focus_object_affect(fo : FocusObject, target : PlayerController, current_position : Vector2, current_scale : float, cam : PlayerCamera) -> FocusObjectOffsetHolder:
	# Variable that will be returned from this object. Defaults to (0, (0, 0))
	var foo : FocusObjectOffsetHolder = FocusObjectOffsetHolder.new(0, Vector2(0, 0))
	
	# First, get a vector that is the player's center
	var player_center : Vector2 = target.global_position - Vector2(0, cam.player_height_offset)
	# If the player is outside its influence, return (0, Vector2(0, 0)) for no affect
	if abs((fo.global_position - player_center).length()) > fo.outer_radius:
		return foo
	# We need one value for both remaining cases, so since this is already expensive, we compute it just once
	else:
		# Get how far the camera would move at the max.
		var offset_to_center = (fo.global_position + fo.target_pos) - player_center
		# First, we handle the case that it's inside the inner radius
		# since it is less computationally expensive
		if abs((fo.global_position - player_center).length()) < fo.inner_radius:
			# Simply return the offset to center * max percentage of the cam pull (usually 1)
			foo.pos = offset_to_center * fo.max_percent
			# Similarly, zoom is just the zoom difference between the current scale and the target
			# times max percent
			foo.zoom = (fo.target_zoom - current_scale) * fo.max_percent
			return foo
		# Finally, we handle the most complex case, where the player is inside the
		# outer radius, but outside the inner radius. Here, we need a fraction
		# of the influence.
		else:
			# First, compute the distance to center
			var distance_to_center = abs((fo.global_position - player_center).length())
			# Next, we compute distance to the inner radius.
			var distance_to_inner_rad = distance_to_center - fo.inner_radius
			# Finally, this is percentage of max_percent to use.
			var affect_percent = 1.0 - (distance_to_inner_rad / (fo.outer_radius - fo.inner_radius))
			# Take the quadradic of the affect_percent for a smoother enter
			affect_percent = pow(affect_percent, 2.)
			# Return the appropriate offset multiplied by the two relevant percentages
			foo.pos = offset_to_center * fo.max_percent * affect_percent
			foo.zoom = (fo.target_zoom - current_scale) * fo.max_percent * affect_percent
			return foo

func get_combined_focus_object_pos_affect(target : PlayerController, current_position : Vector2, current_scale : float, cam : PlayerCamera) -> FocusObjectOffsetHolder:
	var summed_pos_affect : Vector2 = Vector2(0, 0)
	var summed_zoom_affect : float = 0.
	# Iterate through focus objects and compute the affect of each
	for fo in active_focus_objects:
		if fo is FocusObject:
			var foo : FocusObjectOffsetHolder = get_single_focus_object_affect(fo, target, current_position, current_scale, cam)
			summed_pos_affect += foo.pos
			summed_zoom_affect += foo.zoom
	# Return their average
	var foo : FocusObjectOffsetHolder = FocusObjectOffsetHolder.new(summed_zoom_affect / (active_focus_objects.size() as float), summed_pos_affect / (active_focus_objects.size() as float))
	return foo

func get_focus_object_affect(target : PlayerController, current_position : Vector2, current_scale : float, cam : PlayerCamera) -> FocusObjectOffsetHolder:
	var foo : FocusObjectOffsetHolder = get_combined_focus_object_pos_affect(target, current_position, current_scale, cam)
	return FocusObjectOffsetHolder.new(foo.zoom + current_scale, current_position + foo.pos) 


class FocusObjectOffsetHolder:
	var zoom : float
	var pos : Vector2
	
	func _init(z : float, p : Vector2):
		zoom = z
		pos = p 
