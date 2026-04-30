class_name HazardRespawnBox

extends Area2D

# i.e. spikes are directional and only damage when falling into them.
## True if hazard respawn respects direction of motion into it
@export var is_directional : bool = false
@export var damage : int = 0
@export var delay_to_damage : int = 2

# If is directional, set externally to detemine direction
var spike_direction : int

var colliding_bodies : Array = []
var colliding_areas : Array = []

# Assign collision layers on ready
func _ready():
	collision_layer = CollisionDict.HAZARD_RESPAWN_BOX.get_layer()
	collision_mask = CollisionDict.HAZARD_RESPAWN_BOX.get_mask()

func _physics_process(delta: float) -> void:
	for area_and_timer : AreaAndTimer in colliding_areas:
		## Player control: if moving not the direction hazard is facing, do nothing
		## If moving into hazard, count up to 3 frames. If still in collider on 3rd frame,
		## hazard respawn (fast reload scene with hazard respawn location
		if area_and_timer.area is PlayerHurtbox:
			var player : PlayerController = ((area_and_timer as AreaAndTimer).area as PlayerHurtbox).player
			if is_player_moving_into_spikes(player):
				if area_and_timer.timer >= delay_to_damage:
					(area_and_timer.area as PlayerHurtbox).take_damage.emit(damage, false)
					GameManager.LevelManager.load_scene(GameManager.LevelManager.prev_scene_name, GameManager.LevelManager.prev_player_spawn_pos)
				else:
					area_and_timer.timer = area_and_timer.timer + 1

func set_direction(dir : int):
	spike_direction = dir

func is_player_moving_into_spikes(player : PlayerController) -> bool:
	if is_directional:
		match spike_direction:
			CardinalDirections.UP:
				# If player is moving down (or horizontal)
				return player.velocity.y <= 0
			CardinalDirections.DOWN:
				# If player is moving down (or horizontal)
				return player.velocity.y >= 0
			CardinalDirections.RIGHT:
				# If player is moving down (or horizontal)
				return player.velocity.x <= 0
			CardinalDirections.LEFT:
				# If player is moving down (or horizontal)
				return player.velocity.x >= 0
	return true

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# Track bodies on enter
	colliding_bodies.append(BodyAndTimer.new(body, 0))

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# Remove body from being tracked on exit
	var flag : int = -1
	
	for i in range(0, len(colliding_bodies)):
		if colliding_bodies.get(i).body == body:
			flag = i
			break
	
	if flag != -1:
		colliding_bodies.remove_at(flag)

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	# Track areas on enter
	colliding_areas.append(AreaAndTimer.new(area, 0))

func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var flag : int = -1
	
	# Remove area from being tracked on exit
	for i in range(0, len(colliding_areas)):
		if colliding_areas.get(i).area == area:
			flag = i
			break
	
	if flag != -1:
		colliding_areas.remove_at(flag)


## Helper classes for pairing area/body with a timer of how long it has collided for.
class AreaAndTimer:
	var area : Area2D
	var timer : int
	
	func _init(a : Area2D, t : int) -> void:
		area = a
		timer = t

class BodyAndTimer:
	var body : Node2D
	var timer : int
	
	func _init(b : Node2D, t : int) -> void:
		body = b
		timer = t
