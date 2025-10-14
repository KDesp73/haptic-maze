extends CharacterBody2D

const Config = preload("res://src/config.gd")

var speed := Config.PLAYER_SPEED
var size := Config.PLAYER_SIZE
var swipe_threshold := Config.SWIPE_THRESHOLD

# Maze data
var maze: Array
var cell_size: float
var h_offset: float
var v_offset: float

# Grid-based position
var cell := Vector2i.ZERO
var target_cell := Vector2i.ZERO

# For input
var start_pos := Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


# --- PUBLIC ---
func set_maze(m: Array, c_size: float, hor_offset: float, ver_offset: float) -> void:
	maze = m
	cell_size = c_size
	h_offset = hor_offset
	v_offset = ver_offset

	# Set sprite and collision sizes
	_set_bat_size()

	# Find first empty cell
	for y in range(maze.size()):
		for x in range(maze[y].size()):
			if maze[y][x] == 0:
				cell = Vector2i(x, y)
				target_cell = cell
				_update_world_position()
				return


func _ready() -> void:
	Haptics.init()
	if sprite:
		sprite.play("walk")


# --- PRIVATE ---
func _set_bat_size() -> void:
	# Scale sprite to match tile size
	if sprite and sprite.sprite_frames:
		var frame_texture = sprite.sprite_frames.get_frame_texture("walk", 0)
		if frame_texture:
			var scale_factor = cell_size / frame_texture.get_size().x
			sprite.scale = Vector2(scale_factor, scale_factor)
			sprite.centered = true
			sprite.position = Vector2.ZERO

	# Set collision shape slightly smaller than cell to prevent premature collisions
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = cell_size * 0.4
		elif collision_shape.shape is RectangleShape2D:
			collision_shape.shape.size = Vector2(cell_size * 0.8, cell_size * 0.8)
		collision_shape.position = Vector2.ZERO  # center on node


# Converts from cell coords → node position (centered in tile)
func _update_world_position() -> void:
	position = Vector2(
		cell.x * cell_size + cell_size / 2 + h_offset,
		cell.y * cell_size + cell_size / 2 + v_offset
	)


# --- INPUT ---
func _input(event: InputEvent) -> void:
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


func _process_swipe(end_pos: Vector2) -> void:
	if cell != target_cell:
		return # already moving

	var delta := end_pos - start_pos
	if delta.length() < swipe_threshold:
		return

	var dir := Vector2i.ZERO
	if abs(delta.x) > abs(delta.y):
		dir.x = 1 if delta.x > 0 else -1
		if sprite:
			sprite.flip_h = delta.x < 0
	else:
		dir.y = 1 if delta.y > 0 else -1

	var next := target_cell + dir

	# Check boundaries and walls
	if next.y < 0 or next.y >= maze.size():
		_vibrate_wall_hit()
		return
	if next.x < 0 or next.x >= maze[next.y].size():
		_vibrate_wall_hit()
		return
	if maze[next.y][next.x] != 0:
		_vibrate_wall_hit()
		return

	target_cell = next

func _vibrate_wall_hit() -> void:
	Haptics.heavy()

# --- PHYSICS ---
func _physics_process(delta: float) -> void:
	if cell == target_cell:
		velocity = Vector2.ZERO
		return

	var target_pos = Vector2(
		target_cell.x * cell_size + cell_size / 2 + h_offset,
		target_cell.y * cell_size + cell_size / 2 + v_offset
	)

	var diff = target_pos - position
	if diff.length_squared() > 1:
		velocity = diff.normalized() * speed
		move_and_slide()
	else:
		position = target_pos
		cell = target_cell
		velocity = Vector2.ZERO
