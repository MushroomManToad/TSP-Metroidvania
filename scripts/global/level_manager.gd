class_name Level_Manager

var player : PlayerController

# Variables for scene reloading - track the variables passed to load scene for
# later reloading
var prev_player_spawn_pos : Vector2 = Vector2(0.0, 0.0)
var prev_scene_name : String = ""

const PLAYER = preload("res://scenes/entity/player/player.tscn")


func on_ready():
	## TODO: Obviously this is just for testing, level manager should do 
	## nothing on startup - as the title screen will be loaded i.e. no level.
	load_scene("dev/demo_stage", Vector2(0.0, 26.0))
	pass

## TODO: Eventually the "total unload" logic here will be passed onto the
## biome loader for faster scene loading per-biome. When that is done,
## the player should be freed separately from unloading the scene, and
## the scene should be paused.
func load_scene(scene_name : String, player_spawn_pos : Vector2):
	## Read in player data (if it exists, or create new)
	var passable_player_data : PlayerData.PlayerDataPacket
	if player != null:
		passable_player_data = player.player_data.compress_data_to_packet()
		player.queue_free()
	else:
		passable_player_data = PlayerData.PlayerDataPacket.create_with_defaults()
	## TODO: Read in scene semi-persistent data (if it exists, or create new)
	## Load new scene (this method unloads the previous scene completely.)
	GameManager.get_tree().change_scene_to_file("scenes/stage/" + scene_name + ".tscn")
	## Load new Player
	player = PLAYER.instantiate()
	# Set player spawn position as passed
	player.position = player_spawn_pos
	# Pass Player appropriate player data
	player.player_data.load_data_from_packet(passable_player_data)
	# Add as child to tree
	GameManager.get_tree().root.add_child(player)
	## TODO: Pass scene appropriate scene semi-persistent data
	
	## Store spawn pos for usage in scene reloader
	prev_player_spawn_pos = player_spawn_pos
	prev_scene_name = scene_name
