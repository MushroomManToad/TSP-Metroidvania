######################################################################
##                                                                  ##
##  This class serves as an analog for player inventory and stats,  ##
##     storing them for ready access by player and for transfer     ##
##                  across scene loads/transitions                  ##
##                                                                  ##
######################################################################
class_name PlayerData

extends Node2D

var times_jumped : int


######### GENERAL LOAD / COMPRESS METHODS #########
func load_data_from_packet(player_data_packet : PlayerDataPacket) -> void:
	self.times_jumped = player_data_packet.times_jumped

func compress_data_to_packet() -> PlayerDataPacket:
	var data_packet_to_serialize : PlayerDataPacket = PlayerDataPacket.create(
		times_jumped
	)
	return data_packet_to_serialize
######### GENERAL LOAD / COMPRESS METHODS #########


######### Signal catchers #########
func _on_player_jumped() -> void:
	times_jumped += 1


######################################################################
##                                                                  ##
##         Subclass for storing/transfering the loaded data.        ##
##                                                                  ##
######################################################################
class PlayerDataPacket:
	var times_jumped : int
	
	static func create(
		times_jumped : int
	):
		var packet : PlayerDataPacket = PlayerDataPacket.new()
		packet.times_jumped = times_jumped
		return packet
	
	static func create_with_defaults() -> PlayerDataPacket:
		var packet : PlayerDataPacket = PlayerDataPacket.new()
		packet.times_jumped = 0
		return packet
