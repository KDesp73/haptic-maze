extends Node2D

const Config = preload("res://src/config.gd")

@onready var wall_scene = preload("res://Wall.tscn")
@onready var generator = preload("res://src/mazegen.gd").new()

func _ready():
	randomize()

	var screen_size = get_viewport().get_visible_rect().size
	var width = int(screen_size.x / Config.CELL_SIZE)
	var height = int(screen_size.y / Config.CELL_SIZE)

	# Keep maze dimensions odd
	if width % 2 == 0:
		width -= 1
	if height % 2 == 0:
		height -= 1

	var maze = generator.generate_maze(width, height)
	print(maze)
	draw_maze(maze)

func draw_maze(maze: Array):
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			if maze[y][x] == 1:
				var wall = wall_scene.instantiate()
				wall.set_cell_size(Config.CELL_SIZE)
				wall.position = Vector2(x * Config.CELL_SIZE, y * Config.CELL_SIZE)
				add_child(wall)
