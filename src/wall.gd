extends StaticBody2D

@onready var Config := preload("res://src/config.gd")
@export var cell_size: int = Config.CELL_SIZE
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

const BASE_SIZE := 64

func _ready():
	_update_size()

# Public method to update the wall size at runtime
func set_cell_size(size: int) -> void:
	cell_size = size
	call_deferred("_update_size")

func _update_size() -> void:
	if not sprite:
		push_error("Sprite2D not found in Wall scene")
		return
	if not collision:
		push_error("CollisionShape2D not found in Wall scene")
		return

	# Scale the sprite
	var scale_factor = float(cell_size) / BASE_SIZE
	sprite.scale = Vector2(scale_factor, scale_factor)

	# Resize the collision shape
	if collision.shape is RectangleShape2D:
		collision.shape.size = Vector2(cell_size, cell_size)
	else:
		push_warning("CollisionShape2D is not a RectangleShape2D; adjust manually if needed")
