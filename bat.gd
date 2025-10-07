extends AnimatedSprite2D

var speed = 300
var target_pos = Vector2.ZERO

func _ready():
	target_pos = position
	play("walk")

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_pos = event.position

func _process(delta):
	var direction = (target_pos - position).normalized()
	position += direction * speed * delta

	if direction.x < 0:
		flip_h = true
	elif direction.x > 0:
		flip_h = false
