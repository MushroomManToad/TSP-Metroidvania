extends TileMapLayer

func _ready() -> void:
	self.material.set_shader_parameter("enabled", false)
