extends "res://tests/test_suite.gd"

const FOOD_SCENE = preload("res://scenes/food.tscn")

func test_food_spawn() -> void:
	var food = FOOD_SCENE.instantiate()
	add_child(food)
	
	var occupied: Array[Vector2i] = [Vector2i(0,0), Vector2i(1,1)]
	food.spawn(occupied)
	
	assert_true(not food.grid_position in occupied, "Food should not spawn on occupied positions")
	assert_true(food.grid_position.x >= 0 and food.grid_position.x < 20, "X should be in bounds")
	assert_true(food.grid_position.y >= 0 and food.grid_position.y < 20, "Y should be in bounds")
	
	food.queue_free()

func test_food_exhaustive_spawn() -> void:
	var food = FOOD_SCENE.instantiate()
	add_child(food)
	
	# Occupy almost all grid except (5,5)
	var occupied: Array[Vector2i] = []
	for x in range(20):
		for y in range(20):
			if x == 5 and y == 5:
				continue
			occupied.append(Vector2i(x, y))
	
	food.spawn(occupied)
	assert_eq(food.grid_position, Vector2i(5, 5), "Should find the only available spot")
	
	food.queue_free()
