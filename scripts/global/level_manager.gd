class_name Level_Manager

# If existing, stores the player, camera, and stage respectively
var player : PlayerController
var player_camera : PlayerCamera
var loaded_scene : Node

# Variables for scene reloading - track the variables passed to load scene for
# later reloading
var prev_player_spawn_pos : Vector2 = Vector2(0.0, 0.0)
var prev_scene_name : String = ""

const PLAYER = preload("uid://csdluako5yquq")
const PLAYER_CAMERA = preload("uid://cpytagekewbib")

func on_ready():
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
	GameManager.GAME.load_main_scene(scene_name)
	## Load new Player
	player = PLAYER.instantiate()
	# Set player spawn position as passed
	player.position = player_spawn_pos
	# Pass Player appropriate player data
	player.player_data.load_data_from_packet(passable_player_data)
	# Add as child to tree
	GameManager.GAME.load_player(player)
	# TODO: Temp call just so the camera still follows the player
	
	# Camera should be loaded dynamically, but refreshed each time a scene is loaded
	if player_camera:
		player_camera.queue_free()
	player_camera = PLAYER_CAMERA.instantiate()
	GameManager.GAME.load_camera(player_camera)
	player_camera.target = player
	## TODO: Pass scene appropriate scene semi-persistent data
	
	## Store spawn pos for usage in scene reloader
	prev_player_spawn_pos = player_spawn_pos
	prev_scene_name = scene_name
