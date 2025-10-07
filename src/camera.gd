extends Camera2D

const WIDTH = 15
const HEIGHT = 11
const CELL_SIZE = 64

func _ready():
	limit_left = 0
	limit_top = 0
	limit_right = WIDTH * CELL_SIZE
	limit_bottom = HEIGHT * CELL_SIZE
