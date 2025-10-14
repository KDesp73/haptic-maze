extends CharacterBody2D

const Config = preload("res://src/config.gd")
var speed = Config.PLAYER_SPEED
var size = Config.PLAYER_SIZE
var swipe_threshold = Config.SWIPE_THRESHOLD

# Dynamic values passed from the main scene
var cell_size: float
var h_offset: float
var v_offset: float

# Swipe tracking
var start_pos := Vector2.ZERO

# Movement
var direction := Vector2.ZERO
var target_pos := Vector2.ZERO

# Reference to the maze
var maze: Array

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape := $CollisionShape2D

# --- PUBLIC ---
func set_maze(m: Array, c_size: float, hor_offset: float, ver_offset: float) -> void:
	maze = m
	cell_size = c_size
	h_offset = hor_offset
	v_offset = ver_offset
	
	# Snap to the first empty cell using the correct offsets and size
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			if maze[y][x] == 0:
				target_pos = Vector2(
					x * cell_size + cell_size / 2 + h_offset,
					y * cell_size + cell_size / 2 + v_offset
				)
				position = target_pos
				return



func _ready():
	if sprite:
		sprite.play("walk")
		_set_bat_size()

# --- INPUT ---
func _input(event):
	# (Input handling remains the same)
	if event is InputEventScreenTouch:
		if event.pressed:
			start_pos = event.position
		else:
			_process_swipe(event.position)
	elif event is InputEventMouseButton:
		if event.is_pressed():
			start_pos = event.position
		else:
			_process_swipe(event.position)

# --- PRIVATE ---
func _set_bat_size() -> void:
	var anim_name = "walk"
	var frame_texture = sprite.sprite_frames.get_frame_texture(anim_name, 0)
	if not frame_texture:
		push_error("No frame texture found in animation '%s'" % anim_name)
		return

	var original_sprite_size = Vector2(frame_texture.get_size())
	var scale_factor = size / original_sprite_size.x
	sprite.scale = Vector2(scale_factor, scale_factor)

	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape
		if shape is CircleShape2D:
			shape.radius = size / 2.0
		elif shape is RectangleShape2D:
			shape.size = Vector2(size, size)

func _process_swipe(end_pos: Vector2) -> void:
	# We only allow movement if the bat has reached its current target
	# This prevents 'queueing' a second movement before the first finishes
	if (position - target_pos).length_squared() > 1:
		return
		
	var delta = end_pos - start_pos
	if delta.length() < swipe_threshold:
		return

	# Determine cardinal direction
	direction = Vector2.ZERO
	if abs(delta.x) > abs(delta.y):
		direction.x = 1 if delta.x > 0 else -1
		if sprite:
			sprite.flip_h = delta.x < 0
	else:
		direction.y = 1 if delta.y > 0 else -1

	# Get CURRENT cell coordinates, accounting for offset
	# We must subtract the offset before dividing by cell_size
	var adjusted_x = position.x - h_offset
	var adjusted_y = position.y - v_offset
	
	var cell_x = int(adjusted_x / cell_size)
	var cell_y = int(adjusted_y / cell_size)

	# Compute NEXT target cell coordinates
	var next_cell_x = cell_x + int(direction.x)
	var next_cell_y = cell_y + int(direction.y)

	# Check boundaries before accessing the array
	if next_cell_x < 0 or next_cell_x >= maze[0].size() or \
	   next_cell_y < 0 or next_cell_y >= maze.size():
		return

	# Check for walls (0 = empty)
	if maze and maze[next_cell_y][next_cell_x] == 0:
		# Calculate the NEW target position using the correct cell_size and offsets
		target_pos = Vector2(
			next_cell_x * cell_size + cell_size / 2 + h_offset,
			next_cell_y * cell_size + cell_size / 2 + v_offset
		)

# --- PHYSICS ---
func _physics_process(delta):
	var diff = target_pos - position
	
	# Check if we are very close to the target
	if diff.length_squared() > 1: # Using squared length is faster
		# Move towards the target
		velocity = diff.normalized() * speed
		
		# move_and_slide() handles wall collisions automatically
		move_and_slide() 
	else:
		# Snap to the target, stop movement, and clear velocity
		velocity = Vector2.ZERO
		position = target_pos
