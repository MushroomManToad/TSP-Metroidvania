class_name PonyImporterExporter

extends Node2D

@export var pony_base : PonyBase

static var id_pony_name : String = "pony_name"
static var id_num_body_colors : String = "num_body_colors"
static var id_body_colors : String = "body_colors"
static var id_num_eye_colors : String = "num_eye_colors"
static var id_eye_colors : String = "eye_colors"
static var id_num_mane_colors : String = "num_mane_colors"
static var id_mane_colors : String = "mane_colors"
static var id_num_tail_colors : String = "num_tail_colors"
static var id_tail_colors : String = "tail_colors"
static var id_mane_sprite : String = "mane_sprite"
static var id_tail_sprite : String = "tail_sprite"
static var id_butt_mark_colors: String = "butt_mark_colors"

func export_pony(pony_name : String, file_name : String, path_root : String, path : String):
	var file_path = path_root + path + "/" + name_to_filepath(file_name) + ".pony"
	
	var horse_data = {
		id_pony_name : pony_name,
		id_num_body_colors : pony_base.base.get_num_colors(),
		id_body_colors : JSON.stringify(pony_base.base.get_html_colors()),
		id_num_eye_colors : pony_base.eye_color.get_num_colors(),
		id_eye_colors : JSON.stringify(pony_base.eye_color.get_html_colors()),
		id_num_mane_colors : pony_base.stationary.get_num_colors(),
		id_mane_colors : JSON.stringify(pony_base.stationary.get_html_colors()),
		id_num_tail_colors : pony_base.tail.get_num_colors(),
		id_tail_colors : JSON.stringify(pony_base.tail.get_html_colors()),
		id_mane_sprite : pony_base.loaded_mane,
		id_tail_sprite : pony_base.loaded_tail,
		id_butt_mark_colors : JSON.stringify(pony_base.get_butt_mark_color_array()),
	}
	
	var json_string = JSON.stringify(horse_data, "    ")
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("Failed to open file for writing: ", FileAccess.get_open_error())
		return
	
	file.store_string(json_string)

	# Close the file
	file.close()

func import_pony(json_as_dict : Dictionary):
	## Name (for name field)
	if json_as_dict.has(PonyImporterExporter.id_pony_name):
		pony_base.pony_name = json_as_dict.get(PonyImporterExporter.id_pony_name)
	
	## Body NumColor
	if json_as_dict.has(PonyImporterExporter.id_num_body_colors):
		pony_base.set_base_num_colors(json_as_dict.get(PonyImporterExporter.id_num_body_colors))
	
	## Body Color
	if json_as_dict.has(PonyImporterExporter.id_body_colors):
		var body_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_body_colors))
		for i in range(0, 4):
			var c = Color.from_string(body_colors[i], Color.MAGENTA)
			pony_base.recolor_base(i, Vector4(c.r, c.g, c.b, c.a))

	## Eye NumColor
	if json_as_dict.has(PonyImporterExporter.id_num_eye_colors):
		pony_base.set_num_eye_colors(json_as_dict.get(PonyImporterExporter.id_num_eye_colors))
	
	## EyeColor
	if json_as_dict.has(PonyImporterExporter.id_eye_colors):
		var eye_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_eye_colors))
		for i in range(0, 1):
			var c = Color.from_string(eye_colors[i], Color.MAGENTA)
			pony_base.recolor_eye(i, Vector4(c.r, c.g, c.b, c.a))
	
	## Mane Shape
	if json_as_dict.has(PonyImporterExporter.id_mane_sprite):
		var mane_id = json_as_dict.get(PonyImporterExporter.id_mane_sprite)
		var mane_data : PonyIconManeMaster.ManeDataType = GameManager.PONY_ICON_RESOURCE_MANAGER.mane_types.get(mane_id)
		## Mane Color
		var num_mane_colors = 0
		var mane_colors : Array
		mane_colors.resize(8)
		mane_colors.fill(Color.MAGENTA)
		if json_as_dict.has(PonyImporterExporter.id_num_mane_colors):
			num_mane_colors = json_as_dict.get(PonyImporterExporter.id_num_mane_colors)
		if json_as_dict.has(PonyImporterExporter.id_mane_colors):
			mane_colors = str_to_var(json_as_dict.get(PonyImporterExporter.id_mane_colors))
			for i in range(0, len(mane_colors)):
				mane_colors[i] = Color.from_string(mane_colors[i], Color.MAGENTA)
		pony_base.load_mane_from_data(mane_data, mane_colors, num_mane_colors)
	
	## Tail Shape
	if json_as_dict.has(PonyImporterExporter.id_tail_sprite):
		var tail_id = json_as_dict.get(PonyImporterExporter.id_tail_sprite)
		var tail_data : PonyIconTailMaster.TailDataType = GameManager.PONY_ICON_RESOURCE_MANAGER.tail_types.get(tail_id)
		## Mane Color
		var num_tail_colors = 0
		var tail_colors : Array
		tail_colors.resize(8)
		tail_colors.fill(Color.MAGENTA)
		if json_as_dict.has(PonyImporterExporter.id_num_mane_colors):
			num_tail_colors = json_as_dict.get(PonyImporterExporter.id_num_mane_colors)
		if json_as_dict.has(PonyImporterExporter.id_mane_colors):
			tail_colors = str_to_var(json_as_dict.get(PonyImporterExporter.id_mane_colors))
			for i in range(0, len(tail_colors)):
				tail_colors[i] = Color.from_string(tail_colors[i], Color.MAGENTA)
		pony_base.load_tail_from_data(tail_data, tail_colors, num_tail_colors)
	
	## Butt Mark
	if json_as_dict.has(PonyImporterExporter.id_butt_mark_colors):
		var bm_colors : Array = str_to_var(json_as_dict.get(PonyImporterExporter.id_butt_mark_colors))
		var butt_mark_colors : Array = []
		for i in range(0, min(len(bm_colors),49)):
			var color : Color = Color.from_string(bm_colors[i], Color.MAGENTA)
			butt_mark_colors.append(color)
		
		var image = Image.create_empty(8, 8, false, Image.FORMAT_RGBA8)

		for i in range(0, len(butt_mark_colors)):
				@warning_ignore("integer_division")
				image.set_pixel(i % 7, (i / 7) as int, butt_mark_colors[i])

		var image_texture = ImageTexture.create_from_image(image)

		pony_base.butt_mark.texture = image_texture

# I yoinked this straight from Google, thanks Google lol
static func name_to_filepath(input_name : String) -> String:
	# Convert the entire string to lowercase
	var lowercased_string: String = input_name.to_lower()

	# Use RegEx to replace any character that is NOT a word character (a-z, 0-9, or _)
	# The pattern '[^a-z0-9_]' matches all special characters.
	# GDScript has a built-in RegEx class to handle this.
	var pattern := "[^a-z0-9_]"
	var regex := RegEx.new()
	regex.compile(pattern)

	# Replace all matches with an underscore
	var sanitized_string: String = regex.sub(lowercased_string, "_", true)

	# Optional: Replace any sequences of multiple underscores with a single one (e.g., "test!_!" becomes "test__")
	# This keeps the output clean if multiple special characters were adjacent.
	var multi_underscore_pattern := "_{2,}"
	var multi_underscore_regex := RegEx.new()
	multi_underscore_regex.compile(multi_underscore_pattern)
	sanitized_string = multi_underscore_regex.sub(sanitized_string, "_", true)

	return sanitized_string
