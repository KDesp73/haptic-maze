extends Node2D

# Maze generation parameters
const WIDTH = 15
const HEIGHT = 11
const CELL_SIZE = 64

var maze = []

@onready var tilemap = $WallMap
const WALL_TILE_ID = 0  # ID of your wall tile in the TileSet

@onready var bat = $Bat
var target_pos = Vector2.ZERO
var speed = 300

func _ready():
	generate_maze_scene()

# -------------------------
# Maze Generation Functions
# -------------------------
func generate_maze_scene():
	# Initialize maze with walls
	maze = []
	for y in range(HEIGHT):
		var row = []
		for x in range(WIDTH):
			row.append(1)
		maze.append(row)
	
	# Generate maze
	generate_maze(1, 1)
	
	# Draw maze into TileMap
	draw_maze()
	
	# Place bat at starting position (top-left free cell)
	bat.position = Vector2(1, 1) * CELL_SIZE + Vector2(CELL_SIZE/2, CELL_SIZE/2)
	target_pos = bat.position

# Recursive DFS maze generator
func generate_maze(x, y):
	maze[y][x] = 0
	var dirs = [Vector2(0, -2), Vector2(0, 2), Vector2(-2, 0), Vector2(2, 0)]
	dirs.shuffle()
	for d in dirs:
		var nx = x + int(d.x)
		var ny = y + int(d.y)
		if nx > 0 and nx < WIDTH-1 and ny > 0 and ny < HEIGHT-1 and maze[ny][nx] == 1:
			maze[y + int(d.y/2)][x + int(d.x/2)] = 0
			generate_maze(nx, ny)

func draw_maze():
	tilemap.clear()
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if maze[y][x] == 1:
				tilemap.set_cell(x, y, WALL_TILE_ID)

# -------------------------
# Bat Movement
# -------------------------
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_pos = event.position

func _physics_process(delta):
	var direction = (target_pos - bat.position)
	if direction.length() > 1:
		direction = direction.normalized()
		# Move bat with collision
		bat.velocity = direction * speed
		bat.move_and_slide()
		
		# Flip sprite horizontally
		var sprite = bat.get_node("AnimatedSprite2D")
		if direction.x < -0.1:
			sprite.flip_h = true
		elif direction.x > 0.1:
			sprite.flip_h = false
