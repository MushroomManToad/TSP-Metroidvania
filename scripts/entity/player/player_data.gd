######################################################################
##                                                                  ##
##  This class serves as an analog for player inventory and stats,  ##
##     storing them for ready access by player and for transfer     ##
##                  across scene loads/transitions                  ##
##                                                                  ##
######################################################################
class_name PlayerData

extends Node2D

@export var player : PlayerController

var times_jumped : int
var attack_damage : float
var max_health : int
var curr_health : int


######### GENERAL LOAD / COMPRESS METHODS #########
func load_data_from_packet(player_data_packet : PlayerDataPacket) -> void:
	self.times_jumped = player_data_packet.times_jumped
	self.attack_damage = player_data_packet.attack_damages
	self.max_health = player_data_packet.max_health
	self.curr_health = player_data_packet.curr_health

func compress_data_to_packet() -> PlayerDataPacket:
	var data_packet_to_serialize : PlayerDataPacket = PlayerDataPacket.create(
		times_jumped,
		attack_damage,
		max_health,
		curr_health
	)
	return data_packet_to_serialize
######### GENERAL LOAD / COMPRESS METHODS #########


######### Signal catchers #########
func _on_player_jumped() -> void:
	times_jumped += 1

func _on_take_damage(amount: int) -> void:
	# Reduce health by damage, and if health hits zero, die.
	curr_health = max(curr_health - amount, 0)
	# Animate appropriately based on PlayerController functions
	if curr_health == 0:
		player.die()
	else:
		player.on_damaged()


######################################################################
##                                                                  ##
##         Subclass for storing/transfering the loaded data.        ##
##                                                                  ##
######################################################################
class PlayerDataPacket:
	var times_jumped : int
	var attack_damage : float
	var max_health : int
	var curr_health : int
	
	static func create(
		times_jumped : int,
		attack_damage : float,
		max_health : int,
		curr_health : int
	):
		var packet : PlayerDataPacket = PlayerDataPacket.new()
		packet.times_jumped = times_jumped
		packet.attack_damage = attack_damage
		packet.max_health = max_health
		packet.curr_health = curr_health
		return packet
	
	static func create_with_defaults() -> PlayerDataPacket:
		var packet : PlayerDataPacket = PlayerDataPacket.new()
		packet.times_jumped = 0
		packet.attack_damage = 5.0
		packet.max_health = 5
		packet.curr_health = 5
		return packet
