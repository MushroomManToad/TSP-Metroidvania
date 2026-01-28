class_name StageData

extends Node2D

## Camera Bounds Bottom (+) and Top (-)
@export var camera_bT : Vector2i = Vector2i(0, -180)
## Camera Bounds Left (-) and Right (+)
@export var camera_lR : Vector2i = Vector2i(-160, 160)

func _ready() -> void:
	# Sync player camera pos
	GameManager.LevelManager.player.camera.limit_bottom = camera_bT.x
	GameManager.LevelManager.player.camera.limit_top = camera_bT.y
	GameManager.LevelManager.player.camera.limit_left = camera_lR.x
	GameManager.LevelManager.player.camera.limit_right = camera_lR.y
