extends Node2D

@onready var wall_scene = preload("res://scenes/Wall.tscn")
@onready var bat_scene = preload("res://scenes/Bat.tscn")
@onready var generator = preload("res://src/mazegen.gd").new()
const Config = preload("res://src/config.gd")
@onready var target_scene = preload("res://scenes/TargetTile.tscn")

var target_tile: Node = null
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
	var bat_cell = await _add_bat()
	if bat_cell == Vector2.ZERO:
		push_error("Bat was not placed properly")
		return
	var target_cell = _place_target(bat_cell)
	print("Bat placed at", bat_cell)
	print("Target placed at ", target_cell)

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
func _add_bat() -> Vector2:
	var bat = bat_scene.instantiate()
	add_child(bat) # Add first so it can access collisions later
	
	# Wait one frame to ensure walls are ready
	await get_tree().process_frame
	
	# Find a safe spawn cell (empty and not surrounded by walls)
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if maze[y][x] == 0:
				var open_neighbor := false
				
				# Check the 4 neighbors
				for offset in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var nx = x + offset.x
					var ny = y + offset.y
					if nx >= 0 and nx < width and ny >= 0 and ny < height:
						if maze[ny][nx] == 0:
							open_neighbor = true
							break
				
				if open_neighbor:
					# Found a good spot
					bat.set_maze(maze, cell_size, horizontal_offset, vertical_offset)
					bat.cell = Vector2i(x, y)
					bat.target_cell = bat.cell
					bat.position = Vector2(
						x * cell_size + cell_size / 2 + horizontal_offset,
						y * cell_size + cell_size / 2 + vertical_offset
					)
					return bat.cell
	
	push_warning("No valid empty cell found for bat!")
	return Vector2.ZERO


# ----------------------------------------------------------------------

func _place_target(bat_cell: Vector2i) -> Vector2i:
	# BFS setup
	var visited := {}
	var queue := []
	var dist_map := {}

	queue.append(bat_cell)
	visited[bat_cell] = true
	dist_map[bat_cell] = 0

	var directions = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]

	while queue.size() > 0:
		var current = queue.pop_front()
		for dir in directions:
			var next = current + dir
			if next.x < 0 or next.x >= width or next.y < 0 or next.y >= height:
				continue
			if maze[next.y][next.x] != 0:
				continue
			if visited.has(next):
				continue
			visited[next] = true
			dist_map[next] = dist_map[current] + 1
			queue.append(next)

	# Remove bat's current cell from candidates
	dist_map.erase(bat_cell)

	# Find the cell with the largest distance
	var max_dist = -1
	var furthest_cell = bat_cell
	for cell_key in dist_map.keys():
		if dist_map[cell_key] > max_dist:
			max_dist = dist_map[cell_key]
			furthest_cell = cell_key

	# Instantiate the target
	target_tile = target_scene.instantiate()
	target_tile.position = Vector2(
		furthest_cell.x * cell_size + cell_size / 2 + horizontal_offset,
		furthest_cell.y * cell_size + cell_size / 2 + vertical_offset
	)
	target_tile.set_meta("cell", furthest_cell)
	add_child(target_tile)

	return furthest_cell

func _on_target_reached() -> void:
	for i in 3:
		Haptics.medium()
		
		if not is_inside_tree():
			return

		await get_tree().create_timer(0.2).timeout

	if is_inside_tree():
		get_tree().reload_current_scene()

# --- Expose maze to other nodes ---
func get_maze() -> Array:
	return maze

func _physics_process(delta: float) -> void:
	if target_tile == null:
		return
	
	# Get the bat node (assumes only one)
	var bat = get_node_or_null("Bat")
	if bat == null:
		return
	
	# Check if the bat is in the same cell as the target
	if bat.cell == target_tile.get_meta("cell"):
		_on_target_reached()
