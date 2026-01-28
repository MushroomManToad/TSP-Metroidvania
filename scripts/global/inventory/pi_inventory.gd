class_name PI_Inventory

extends Node

var pi : Persistent_Inventory

func on_ready(pi : Persistent_Inventory):
	self.pi = pi
	pass

func load_data(in_val : Dictionary):
	pass

func get_save_data() -> Dictionary:
	var ret_data = {}
	
	return ret_data
