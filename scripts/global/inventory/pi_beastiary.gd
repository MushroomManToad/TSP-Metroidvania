class_name PI_Beastiary

extends Node

var pi : Persistent_Inventory

## ENTITY KEYS
const GRASS_CRAWLER : String = "enemy.grass_crawler"
const CONSCIOUS_ECHO : String = "enemy.conscious_echo"
const THOUGHT_WISP : String = "enemy.thought_wisp"

var beastiary_registry : Dictionary[String, DictionaryEntry] = {}

func on_ready(pi : Persistent_Inventory):
	self.pi = pi
	build_beastiary()

## Build the beastiary from file
func load_data(in_val : Dictionary):
	pass

func get_save_data() -> Dictionary[String, int]:
	var ret_data : Dictionary[String, int] = {}
	for entry in beastiary_registry.keys():
		ret_data.set(entry, (beastiary_registry.get(entry) as DictionaryEntry).get_kill_count())
	return ret_data

func build_beastiary():
	beastiary_registry = {
		GRASS_CRAWLER : DictionaryEntry.new(GRASS_CRAWLER, 30),
		CONSCIOUS_ECHO : DictionaryEntry.new(CONSCIOUS_ECHO, 25),
		THOUGHT_WISP : DictionaryEntry.new(THOUGHT_WISP, 25)
	}

func add_kill(id : String) :
	pass

class DictionaryEntry:
	# Entity name
	var v_name
	# Current kill count
	var kill_count = 0
	# Kills required to complete entry
	var max_kills
	# Base description before max have been killed
	var v_desc_base
	# Additional flavor text after entry is completed
	var v_desc_unlock
	
	func _init(v_name : String, max_kills : int):
		self.v_name = v_name
		self.max_kills = max_kills
		self.v_desc_base = v_name + "_desc_base"
		self.v_desc_unlock = v_name + "_desc_unlock"
	
	func get_kill_count() -> int:
		return kill_count
