extends Node2D

@onready var wall_scene = preload("res://scenes/Wall.tscn")
@onready var generator = preload("res://src/mazegen.gd").new()
const Config = preload("res://src/config.gd")

var maze = null

func _ready() -> void:
	randomize()
	
	var screen_size = get_viewport().get_visible_rect().size
	var width = int(screen_size.x / Config.CELL_SIZE)
	var height = int(screen_size.y / Config.CELL_SIZE)

	# Keep maze dimensions odd
	if width % 2 == 0:
		width -= 1
	if height % 2 == 0:
		height -= 1

	# Generate the maze (2D array: 0 = path, 1 = wall)
	maze = generator.generate_maze(width, height)
	
	# Build walls based on maze data
	_build_maze()


func _build_maze() -> void:
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			if maze[y][x] == 1:
				var wall = wall_scene.instantiate()
				wall.position = Vector2(x * Config.CELL_SIZE, y * Config.CELL_SIZE)
				add_child(wall)
