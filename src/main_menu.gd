extends Node

const GAME_SCENE := preload("res://scenes/Main.tscn")
@onready var prompt := $AudioStreamPlayer
@onready var container := $CenterContainer
@onready var title := $CenterContainer/VBoxContainer/TitleLabel
@onready var message := $CenterContainer/VBoxContainer/MessageLabel
@onready var Haptics := preload("res://src/haptics.gd").new()
var can_start := false

func _ready():
	_styling()
	
	await get_tree().create_timer(1.0).timeout
	can_start = true
	
	# Play voice prompt
	if prompt:
		prompt.play()

func _input(event):
	if not can_start:
		return

	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed):
		_start_game()

func _start_game():
	Haptics.effect(AndroidHaptics.Effect.CLICK)
	
	get_tree().change_scene_to_packed(GAME_SCENE)

func _styling():
	var screen_size = get_viewport().get_visible_rect().size
	container.set_size(screen_size)
	$CenterContainer/VBoxContainer.set_size(screen_size)
	container.set_begin(Vector2.ZERO)
	
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_font_size_override("font_size", 60)

	message.add_theme_color_override("font_color", Color(1,1,1,0.8))
	message.add_theme_font_size_override("font_size", 30)
