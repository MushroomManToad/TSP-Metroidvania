class_name Game_Settings

# NOTE: DO NOT USE ARRAYS OR DICTIONARIES HERE, EVERYTHING WILL BREAK
# ANY VALUE THAT MUST BE SERIALIZED MUST BE DONE INDEPENDENTLY (or cleverly)

## AUDIO
var MASTER_VOLUME : SettingsVariant = SettingsVariant.new("master_volume", 1.0)
var MUSIC_VOLUME : SettingsVariant = SettingsVariant.new("music_volume", 1.0)
var SFX_VOLUME : SettingsVariant = SettingsVariant.new("sfx_volume", 1.0)
var PROTAG_VOLUME : SettingsVariant = SettingsVariant.new("protag_volume", 1.0)
var NPC_VOLUME : SettingsVariant = SettingsVariant.new("npc_volume", 1.0)
var AMBIENT_VOLUME : SettingsVariant = SettingsVariant.new("ambient_volume", 1.0)

## GAMEPLAY
var LANGUAGE : SettingsVariant = SettingsVariant.new("language", Language.EN)

## GRAPHICS
var RESOLUTION : SettingsVariant = SettingsVariant.new("resolution", Vector2(1280., 720.))
var DISPLAY_MODE : SettingsVariant = SettingsVariant.new("display_mode", DisplayMode.WINDOWED)

## BINDINGS
# (min, max) -> Controls the range over which walk stick strength actually varies
# i.e. at default (0.2, 0.7), player has no horizontal movement below 0.2
# and moves at full speed about 0.7
var WALK_DEADZONE : SettingsVariant = SettingsVariant.new("walk_deadzone", 0.2)


var SETTINGS_REGISTRY : Array[SettingsVariant]
func construct_registry():
	## Empty Array so variables cannot be duplicated in registry
	SETTINGS_REGISTRY.clear()
	## AUDIO
	SETTINGS_REGISTRY.append(MASTER_VOLUME)
	SETTINGS_REGISTRY.append(MUSIC_VOLUME)
	SETTINGS_REGISTRY.append(SFX_VOLUME)
	SETTINGS_REGISTRY.append(PROTAG_VOLUME)
	SETTINGS_REGISTRY.append(NPC_VOLUME)
	SETTINGS_REGISTRY.append(AMBIENT_VOLUME)
	
	## GAMEPLAY
	SETTINGS_REGISTRY.append(LANGUAGE)
	
	## GRAPHICS
	SETTINGS_REGISTRY.append(RESOLUTION)
	SETTINGS_REGISTRY.append(DISPLAY_MODE)
	
	## BINDINGS
	SETTINGS_REGISTRY.append(WALK_DEADZONE)


func on_ready():
	## Load data including language from saved settings.
	construct_registry()
	load_settings()


func load_settings():
	if FileAccess.file_exists(get_settings_filepath()):
		# Read in settings and update flags accordingly
		read_in_from_file()
		sync_to_real_values()
	else:
		# If no settings file yet exists, create a new one with default values
		create_with_defaults()
		sync_to_real_values()

func create_with_defaults():
	for sv in SETTINGS_REGISTRY:
		sv.val = sv.default_val
	serialize_values()

func read_in_from_file():
	# This case should literally never happen because we checked it 2 lines ago
	# but ya know, just in case. Plus this method could be called elsewhere.
	# Still, settings should have been made on game launch
	if not FileAccess.file_exists(get_settings_filepath()):
		push_warning("NO SETTINGS FILE FOUND. CREATING NEW FILE.")
		create_with_defaults()
		return
	
	# Open File
	var save_file = FileAccess.open(get_settings_filepath(), FileAccess.READ)
	
	# Read in content for validation
	var content = save_file.get_as_text()
	
	# Validation ripped straight off the internet
	var json = JSON.new()
	var error = json.parse(content)

	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			# Since we know it's a valid dictionary, read it in
			var json_dict : Dictionary = JSON.parse_string(FileAccess.get_file_as_string(get_settings_filepath()))
			# And iterate through settings to read in their values
			for sv in SETTINGS_REGISTRY:
				# Set as default if no value found. It'll work in game
				# and serialize the next time the settings file serializes
				# (i.e. on changed value)
				var read_in_val = json_dict.get(sv.id, sv.default_val)
				# Handle the vector case, which is not handled by default in JSON
				if read_in_val is String and read_in_val[0] == '(':
					# Split up the input into an array
					var array: Array = read_in_val.erase(0, 1).erase(read_in_val.length() - 1, 1).split(", ")
					
					# Convert to Vectors as appropriate
					match len(array):
						2:
							read_in_val = Vector2(type_convert(array[0], TYPE_FLOAT), type_convert(array[1], TYPE_FLOAT))
						3:
							read_in_val = Vector3(type_convert(array[0], TYPE_FLOAT), type_convert(array[1], TYPE_FLOAT), type_convert(array[2], TYPE_FLOAT))
						4:
							read_in_val = Vector4(type_convert(array[0], TYPE_FLOAT), type_convert(array[1], TYPE_FLOAT), type_convert(array[2], TYPE_FLOAT), type_convert(array[3], TYPE_FLOAT))
				sv.val = type_convert(read_in_val, typeof(sv.default_val))
		else:
			# In error cases, log error and recreate settings with defaults.
			push_error("SETTINGS FILE CORRUPTED. Generating new settings file")
			create_with_defaults()
	else:
		# In error cases, log error and recreate settings with defaults.
		push_error("SETTINGS FILE CORRUPTED. Generating new settings file")
		create_with_defaults()

func sync_to_real_values():
	## AUDIO
	
	
	## GAMEPLAY
	
	
	## GRAPHICS
	DisplayServer.window_set_size(Vector2i(RESOLUTION.val.x as int, RESOLUTION.val.y as int))
	match DISPLAY_MODE:
		DisplayMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	## BINDINGS
	

func serialize_values():
	# Construct the serialization dictionary
	var json_dict : Dictionary = {}
	for sv in SETTINGS_REGISTRY:
		json_dict.set(sv.id, sv.val)
	# Open the settings file
	var save_file = FileAccess.open(get_settings_filepath(), FileAccess.WRITE)
	if save_file:
		# Write in the dictionary
		save_file.store_line(JSON.stringify(json_dict, "\t"))

# Helper function to guarantee filepath is consistent
func get_settings_filepath() -> String:
	return "user://SETTINGS.json"

# Helper Enum for handling the different display types for settings
enum DisplayMode {
	FULLSCREEN,
	WINDOWED,
	BORDERLESS
}

class SettingsVariant:
	var id : String
	var val : Variant :
		get:
			return val
		set(value):
			val = value
			if typeof(val) != typeof(default_val):
				printerr("WARNING: ", id, " HAS SEPARATE TYPED VALUE AND DEFAULT: " + str(typeof(val)) + " and " + str(typeof(default_val)))
	var default_val : Variant
	func _init(name : String, default_value : Variant):
		id = name
		default_val = default_value
		val = default_val
	
	func _to_string() -> String:
		return id + ": " + str(val) + ", " + str(default_val)
