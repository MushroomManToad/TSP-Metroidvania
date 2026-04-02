class_name ManeTailButton

extends TextureButton

@onready var icon: TextureRect = $Icon
var pony_base : PonyBase
var mane_data : PonyIconManeMaster.ManeDataType
var tab_manager : PonyCCManeTabManager

func set_pony_base(pb : PonyBase):
	pony_base = pb

func set_mane_data(md):
	mane_data = md

func _ready() -> void:
	icon.texture = mane_data.icon

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# Set this to be the only button pressed
		tab_manager.depress_all()
		
		# num_colors is used for enabling color buttons and assigning 
		# shader values for mane components
		var num_colors = len(mane_data.colors)
		
		# Reset locks and set new locks
		tab_manager.unlock_all()
		
		# Enable the correct buttons
		for i in range(0, 8, 1):
			if i < num_colors:
				tab_manager.enable_button(tab_manager.color_buttons[i])
			else:
				tab_manager.disable_button(tab_manager.color_buttons[i])
		
		for lock in mane_data.locks:
			if lock is Array and len(lock) == 2:
				var locked_node = tab_manager.color_buttons[lock[1]]
				var locker_node = tab_manager.color_buttons[lock[0]]
				
				locked_node.lock_source = locker_node
				locked_node.enable_lock(not tab_manager.color_mode_keep)
				# Set appropriate color offsets
				var hue_offset = mane_data.colors[lock[1]].h - mane_data.colors[lock[0]].h
				var val_offset = mane_data.colors[lock[1]].v / mane_data.colors[lock[0]].v
				var sat_offset = mane_data.colors[lock[1]].s / mane_data.colors[lock[0]].s
				
				locked_node.set_hsv_offset(hue_offset, sat_offset, val_offset)
			else:
				push_warning("Invalid lock in in mane_data " + str(lock))
		
		# Set node colors IFF not in keep mode
		if not tab_manager.color_mode_keep:
			for i in range(0, len(mane_data.colors)):
				tab_manager.color_buttons[i].update_color(mane_data.colors[i])
			
		# Set the internal mane_id of pony_base for later export.
		pony_base.loaded_mane = mane_data.id
		
		# Set textures (method handles IFs for nulls)
		pony_base.set_mane_textures(
			mane_data.bounce_back,
			mane_data.stationary_back,
			mane_data.stationary,
			mane_data.stationary_front,
			mane_data.bounce_front
		)
		
		# Propogate new num_colors, out_colors, and, if not keep mode, in_colors
		var in_colors : Array[Vector4] = []
		var out_colors : Array[Vector4] = []
		for i in range(0, len(mane_data.colors), 1):
			in_colors.append(Vector4(
				mane_data.colors[i].r, 
				mane_data.colors[i].g, 
				mane_data.colors[i].b, 
				mane_data.colors[i].a)
				)
			out_colors.append(Vector4(
				mane_data.colors[i].r, 
				mane_data.colors[i].g, 
				mane_data.colors[i].b, 
				mane_data.colors[i].a)
				)
		pony_base.set_mane_colors_different_in(in_colors, out_colors)
	# Catches both cases - no need to reuse code lol
	set_pressed_no_signal(true)

func set_mane_tab_manager(manager : PonyCCManeTabManager):
	tab_manager = manager

func _on_mouse_entered() -> void:
	grab_focus()

func _on_mouse_exited() -> void:
	release_focus()
