extends Node2D

@onready var sprite = $Sprite2D
const BASE_SIZE = 64

func set_cell_size(size: int):
	if not sprite:
		push_error("Sprite2D not found in Wall scene")
		return

	var scale_factor = float(size) / BASE_SIZE
	sprite.scale = Vector2(scale_factor, scale_factor)
