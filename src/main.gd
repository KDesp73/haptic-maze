extends Node2D

const Config = preload("res://src/config.gd")
@onready var MazeScene = preload("res://scenes/Maze.tscn")

func _ready() -> void:
	var maze_instance = MazeScene.instantiate()
	maze_instance.position = Vector2.ZERO
	add_child(maze_instance)
	var maze = maze_instance.get_maze()
	
	print(maze)
