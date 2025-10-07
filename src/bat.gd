extends AnimatedSprite2D

var speed = 300
var target_pos = Vector2.ZERO
const SCALE = 0.2

func _ready():
	target_pos = position
	play("walk")
	scale = Vector2(SCALE, SCALE)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_pos = event.position
	
	# NOTE: for debugging purposes
	if event is InputEventMouse and event.is_pressed():
		target_pos = event.position

func _process(delta):
	var direction = (target_pos - position).normalized()
	position += direction * speed * delta

	if direction.x < 0:
		flip_h = true
	elif direction.x > 0:
		flip_h = false
