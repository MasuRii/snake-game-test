extends Node2D

class_name Food

const TILE_SIZE = 32
const GRID_WIDTH = 20
const GRID_HEIGHT = 20

var grid_position: Vector2i = Vector2i.ZERO

func spawn(occupied_positions: Array[Vector2i]) -> void:
	var attempts = 0
	var found = false
	
	while attempts < 100:
		var pos = Vector2i(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
		if not pos in occupied_positions:
			grid_position = pos
			position = Vector2(grid_position * TILE_SIZE)
			found = true
			break
		attempts += 1
	
	if not found:
		# Fallback to exhaustive search if random fails many times
		var valid_positions: Array[Vector2i] = []
		for x in range(GRID_WIDTH):
			for y in range(GRID_HEIGHT):
				var pos = Vector2i(x, y)
				if not pos in occupied_positions:
					valid_positions.append(pos)
		
		if not valid_positions.is_empty():
			grid_position = valid_positions[randi() % valid_positions.size()]
			position = Vector2(grid_position * TILE_SIZE)
