extends Node

class_name MazeGenerator

func generate_maze(width: int, height: int) -> Array:
	var maze = []
	for y in range(height):
		maze.append([])
		for x in range(width):
			maze[y].append(1)  # 1 = wall, 0 = path
	
	var stack = []
	var start = Vector2i(1, 1)
	maze[start.y][start.x] = 0
	stack.append(start)

	var dirs = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

	while stack.size() > 0:
		var current = stack.back()
		var neighbors = []
		for d in dirs:
			var next = current + d * 2
			if next.x > 0 and next.y > 0 and next.x < width - 1 and next.y < height - 1:
				if maze[next.y][next.x] == 1:
					neighbors.append(d)

		if neighbors.size() > 0:
			var dir = neighbors[randi() % neighbors.size()]
			var between = current + dir
			var next = current + dir * 2
			maze[between.y][between.x] = 0
			maze[next.y][next.x] = 0
			stack.append(next)
		else:
			stack.pop_back()

	return maze
