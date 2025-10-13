extends Camera2D
 
const WIDTH = 15
const HEIGHT = 11

const Config = preload("res://src/config.gd")

func _ready():
	limit_left = 0
	limit_top = 0
	var screen_size = get_viewport().get_visible_rect().size
	limit_right = screen_size.x
	limit_bottom = screen_size.y
