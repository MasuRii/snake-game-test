extends "res://tests/test_suite.gd"

const MAIN_SCENE = preload("res://scenes/main.tscn")

func test_game_over_on_wall_collision() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child(main)
	
	var game_state = get_node("/root/GameState")
	game_state.set_state(1) # PLAYING
	
	var snake = main.get_node("Snake")
	var new_positions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	snake.positions = new_positions
	snake.direction = Vector2i.LEFT
	
	snake.move() # This should emit collided_with_wall
	
	assert_eq(game_state.current_state, 3, "State should be GAME_OVER (3) after wall collision")
	
	main.queue_free()

func test_food_consumption() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child(main)
	
	var game_state = get_node("/root/GameState")
	game_state.reset_score()
	game_state.set_state(1) # PLAYING
	
	var snake = main.get_node("Snake")
	var food = main.get_node("Food")
	
	# Place food in front of snake
	var snake_pos: Array[Vector2i] = [Vector2i(10, 10), Vector2i(9, 10), Vector2i(8, 10)]
	snake.positions = snake_pos
	snake.direction = Vector2i.RIGHT
	food.grid_position = Vector2i(11, 10)
	food.position = Vector2(11 * 32, 10 * 32)
	
	main._on_game_timer_timeout() # Process one tick
	
	assert_eq(game_state.current_score, 10, "Score should increase by 10")
	assert_eq(snake.positions.size(), 4, "Snake should grow (3 initial + 1 from food)")
	
	main.queue_free()
