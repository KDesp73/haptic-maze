extends Node2D

@onready var wall_scene = preload("res://scenes/Wall.tscn")
@onready var bat_scene = preload("res://scenes/Bat.tscn")
@onready var generator = preload("res://src/mazegen.gd").new()
const Config = preload("res://src/config.gd")

var maze: Array
var cell_size: float
var width: int
var height: int
var vertical_offset: float = 0.0
var horizontal_offset: float = 0.0

func _ready() -> void:
	randomize()

	var screen_size = get_viewport().get_visible_rect().size

	# --- 1. Compute Base Maze Dimensions ---
	# Use an estimate for initial cell count (e.g., from Config)
	# This determines the complexity/aspect ratio of the maze
	var base_cell_size = Config.CELL_SIZE

	width = int(screen_size.x / base_cell_size)
	height = int(screen_size.y / base_cell_size)

	# Keep dimensions odd for proper maze generation
	if width % 2 == 0:
		width -= 1
	if height % 2 == 0:
		height -= 1

	# --- 2. Calculate Cell Size for Perfect Fit and Centering ---
	# Calculate cell size based on the most restrictive dimension (smallest size to fit all cells)
	var cell_size_x = screen_size.x / width
	var cell_size_y = screen_size.y / height
	
	# Use the smaller of the two to ensure the entire maze fits on screen
	cell_size = min(cell_size_x, cell_size_y)

	# Compute total dimensions based on the new cell_size
	var total_maze_width = cell_size * width
	var total_maze_height = cell_size * height

	# Compute offsets to center the maze within the remaining screen space
	horizontal_offset = (screen_size.x - total_maze_width) / 2
	vertical_offset = (screen_size.y - total_maze_height) / 2
	
	# Generate maze (2D array: 0 = empty, 1 = wall)
	maze = generator.generate_maze(width, height)

	# Build walls
	_build_walls()

	# Add bat
	_add_bat()

# ----------------------------------------------------------------------

# --- Build wall nodes ---
func _build_walls() -> void:
	for y in range(height):
		for x in range(width):
			if maze[y][x] == 1:
				var wall = wall_scene.instantiate()
				
				if wall.has_method("set_cell_size"):
					wall.set_cell_size(cell_size) 
					
				# Position wall in the center of its cell
				wall.position = Vector2(
					x * cell_size + cell_size / 2 + horizontal_offset,
					y * cell_size + cell_size / 2 + vertical_offset
				)
				add_child(wall)

# ----------------------------------------------------------------------

# --- Add bat in first empty cell ---
func _add_bat() -> void:
	var bat = bat_scene.instantiate()
	
	# PASS the dynamic cell_size and offsets
	bat.set_maze(maze, cell_size, horizontal_offset, vertical_offset) 
	add_child(bat)
	
	for y in range(height):
		for x in range(width):
			if maze[y][x] == 0:
				# Snap bat to center of first empty cell
				bat.position = Vector2(
					x * cell_size + cell_size / 2 + horizontal_offset,
					y * cell_size + cell_size / 2 + vertical_offset
				)
				bat.target_pos = bat.position
				return # Stop after finding the first empty cell

# ----------------------------------------------------------------------

# --- Expose maze to other nodes ---
func get_maze() -> Array:
	return maze
