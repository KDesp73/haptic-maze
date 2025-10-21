extends Node2D

const Config = preload("res://src/config.gd")
@onready var MazeScene = preload("res://scenes/Maze.tscn")
@onready var MenuScene = preload("res://scenes/PauseMenu.tscn")

var menu_instance: Node = null
var last_tap_time := 0.0
var double_tap_max_delay := 0.3

var maze_instance

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	maze_instance = MazeScene.instantiate()
	maze_instance.position = Vector2.ZERO
	add_child(maze_instance)

	_apply_glitch_mode()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		var now := Time.get_ticks_msec() / 1000.0
		if now - last_tap_time < double_tap_max_delay:
			_toggle_menu()
		last_tap_time = now


func _toggle_menu() -> void:
	if menu_instance == null:
		menu_instance = MenuScene.instantiate()
		add_child(menu_instance)
		menu_instance.visible = true
		get_tree().paused = true

		# Connect checkbox signal
		menu_instance.connect("glitch_mode_changed", Callable(self, "_on_glitch_mode_changed"))

		# Set checkbox to current glitch state
		menu_instance.set_checkbox_state(Globals.glitch_mode_enabled)
	else:
		menu_instance.queue_free()
		menu_instance = null
		get_tree().paused = false


# Called whenever checkbox toggled
func _on_glitch_mode_changed(enabled: bool) -> void:
	Globals.glitch_mode_enabled = enabled
	_apply_glitch_mode()


func _apply_glitch_mode() -> void:
	if maze_instance == null:
		return
	_apply_glitch_recursive(maze_instance, Globals.glitch_mode_enabled)


func _apply_glitch_recursive(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child.name != "Bat":
			child.visible = not enabled
			_apply_glitch_recursive(child, enabled)
