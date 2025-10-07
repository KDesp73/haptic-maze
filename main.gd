extends Node2D

var speed = 300
var target_pos = Vector2.ZERO

func _ready():
	target_pos = $Bat.position

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		target_pos = event.position

func _process(delta):
	$Bat.position = $Bat.position.move_toward(target_pos, speed * delta)
