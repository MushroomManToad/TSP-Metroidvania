class_name Language_Directory

# Maps text keys to the loaded language's text files.
var loaded_dictionary : Dictionary

func on_ready():
	pass
	## This is now called from the settings class
	#load_dictionary_from_language(GameManager.GameSettings.LANGUAGE.val as int)

# Given a language, sets the loaded dictionary to that language
func load_dictionary_from_language(lang : int):
	loaded_dictionary.clear()
	var file = FileAccess.open("res://lang/game_text.csv", FileAccess.READ)
	# Dump header
	file.get_csv_line(";")
	# Read all lines
	while !file.eof_reached():
		# Read the next line to csv_row
		var csv_row = file.get_csv_line(";")
		# Only read in row if it has content.
		if csv_row.size() > lang + 1:
			# Load into dictionary
			loaded_dictionary.get_or_add(csv_row[0], csv_row[lang + 1])
		# Any improperly-loaded row will be dumped and print to log - ignoring
		# those with size 1, as they are likely empty entries.
		elif csv_row.size() > 1:
			print("Dumped language entry with name \"", csv_row[0], "\".")
	file.close()

func translate(key : String) -> String:
	if loaded_dictionary.has(key):
		return loaded_dictionary.get(key)
	# Default to the passed value if key is not present. 
	# This should be obvious in-game, but also print a warn.
	push_warning("Translation key ", key, " not found in dictionary ", str(GameManager.GameSettings.LANGUAGE))
	return key
