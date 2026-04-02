extends Node2D

@onready var pupil: Sprite2D = $Pupil
@onready var eye_color: Sprite2D = $EyeColor
@onready var pony_base: Sprite2D = $PonyBase
@onready var horn: Sprite2D = $Horn

func set_coat_color(c : Color):
	pony_base.modulate = Color(c.r, c.g, c.b, 1.0)
	horn.modulate = Color(c.r, c.g, c.b, 1.0)

func set_eye_color(c : Color):
	eye_color.modulate = Color(c.r, c.g, c.b, 1.0)
	
