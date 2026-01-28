## THIS CLASS MANAGES THE SAVE FILE SYSTEM. ALL SAVED FILES GO HERE.
class_name Persistent_Inventory

extends Node

## The persisten inventory system holds values attached to the 4 main inventory screens of the player, namely:
## Map, Beastiary, Inventory, Equipment
## Additionally, holds WorldData such as levers hit, collectables picked up, and conversation progress.
## AdditionalData holds anything else that needs to be serialized, such as last save point.

# Variables for each data registry.
var AdditionalData : PI_AdditionalData
var Beastiary : PI_Beastiary
var Equipment : PI_Equipment
var Inventory : PI_Inventory
var Map : PI_Map
var WorldData : PI_WorldData

func on_ready():
	# Initialize all sub-systems to default values on game load.
	AdditionalData = PI_AdditionalData.new()
	Beastiary = PI_Beastiary.new()
	Equipment = PI_Equipment.new()
	Inventory = PI_Inventory.new()
	Map = PI_Map.new()
	WorldData = PI_WorldData.new()
	
	AdditionalData.on_ready(self)
	Beastiary.on_ready(self)
	Equipment.on_ready(self)
	Inventory.on_ready(self)
	Map.on_ready(self)
	WorldData.on_ready(self)

## Primary function called when a save file is loaded
func load_game(id):
	if not FileAccess.file_exists("user://save" + str(id) + ".floof"):
		push_error("A CRITICAL ERROR HAS OCCURRED: SAVE FILE NOT FOUND!")
		## TODO: Try backup file
		return
	
	var save_file = FileAccess.open("user://save" + str(id) + ".floof", FileAccess.READ)
	
	var array_of_data = []
	
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		# Creates the helper class to interact with JSON.
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		# Get the data from the JSON object.
		var node_data = json.data
		
		array_of_data.append(node_data)
	
	if array_of_data.size() >= 6:
		AdditionalData.load_data(array_of_data[0])
		Beastiary.load_data(array_of_data[1])
		Equipment.load_data(array_of_data[2])
		Inventory.load_data(array_of_data[3])
		Map.load_data(array_of_data[4])
		WorldData.load_data(array_of_data[5])

## Primary function called when the game is saved
func save_game(id):
	var save_file = FileAccess.open("user://save" + str(id) + ".floof", FileAccess.WRITE)
	if save_file:
		# Additional Data
		save_file.store_line(JSON.stringify(AdditionalData.get_save_data()))
		# Beastiary
		save_file.store_line(JSON.stringify(Beastiary.get_save_data()))
		# Equipment
		save_file.store_line(JSON.stringify(Equipment.get_save_data()))
		# Inventory
		save_file.store_line(JSON.stringify(Inventory.get_save_data()))
		# Map
		save_file.store_line(JSON.stringify(Map.get_save_data()))
		# World Data
		save_file.store_line(JSON.stringify(WorldData.get_save_data()))
		save_file.close()
