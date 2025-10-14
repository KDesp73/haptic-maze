extends Area2D

const Config = preload("res://src/config.gd")
var cell_size = Config.CELL_SIZE

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	if color_rect:
		color_rect.set_size(Vector2(cell_size, cell_size))
		color_rect.position = -color_rect.size / 2
