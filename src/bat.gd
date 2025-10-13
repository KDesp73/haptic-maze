extends AnimatedSprite2D

const Config = preload("res://src/config.gd")

var speed = Config.PLAYER_SPEED
var direction := Vector2.ZERO
const SWIPE_THRESHOLD := 50  # Minimum distance for a swipe to count
var start_pos := Vector2.ZERO
const SCALE = Config.PLAYER_SCALE

func _ready():
	play("walk")
	scale = Vector2(SCALE, SCALE)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Start of swipe
			start_pos = event.position
		else:
			# End of swipe
			var delta = event.position - start_pos

			if delta.length() < SWIPE_THRESHOLD:
				return  # Ignore short swipes

			# Determine swipe direction (no diagonals)
			if abs(delta.x) > abs(delta.y):
				if delta.x > 0:
					direction = Vector2.RIGHT
					flip_h = false
				else:
					direction = Vector2.LEFT
					flip_h = true
			else:
				if delta.y > 0:
					direction = Vector2.DOWN
				else:
					direction = Vector2.UP

	# Optional: mouse for debugging
	if event is InputEventMouseButton and event.is_pressed():
		start_pos = event.position
	elif event is InputEventMouseButton and not event.is_pressed():
		var delta = event.position - start_pos
		if abs(delta.x) > abs(delta.y):
			direction = Vector2.RIGHT if delta.x > 0 else Vector2.LEFT
			flip_h = delta.x < 0
		else:
			direction = Vector2.DOWN if delta.y > 0 else Vector2.UP

func _process(delta):
	position += direction * speed * delta
