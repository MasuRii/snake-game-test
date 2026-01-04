extends "res://tests/test_suite.gd"

const SNAKE_SCENE = preload("res://scenes/snake.tscn")

func test_initial_snake_state() -> void:
	var snake = SNAKE_SCENE.instantiate()
	add_child(snake)
	
	# reset() is called in _ready()
	# reset() adds 1 pos, then grow() x2. So 3 positions.
	assert_eq(snake.positions.size(), 3, "Should start with 3 positions after reset (1 initial + 2 grows)")
	assert_eq(snake.direction, Vector2i.RIGHT, "Should start moving right")
	assert_eq(snake.body_segments.size(), 3, "Should start with 3 segments")
	
	snake.queue_free()

func test_snake_direction_change() -> void:
	var snake = SNAKE_SCENE.instantiate()
	add_child(snake)
	
	snake._queue_direction(Vector2i.UP)
	snake.move()
	assert_eq(snake.direction, Vector2i.UP, "Direction should change to UP")
	
	snake.queue_free()

func test_snake_prevent_180_turn() -> void:
	var snake = SNAKE_SCENE.instantiate()
	add_child(snake)
	
	snake.direction = Vector2i.RIGHT
	snake._queue_direction(Vector2i.LEFT)
	assert_eq(snake.input_queue.size(), 0, "Should not queue opposite direction")
	
	snake.queue_free()

func test_snake_movement() -> void:
	var snake = SNAKE_SCENE.instantiate()
	add_child(snake)
	
	var initial_pos = snake.positions[0]
	snake.direction = Vector2i.RIGHT
	snake.move()
	assert_eq(snake.positions[0], initial_pos + Vector2i.RIGHT, "Should move one tile right")
	
	snake.queue_free()

func test_snake_growth() -> void:
	var snake = SNAKE_SCENE.instantiate()
	add_child(snake)
	
	var initial_size = snake.body_segments.size()
	snake.grow()
	assert_eq(snake.body_segments.size(), initial_size + 1, "Should increase segment count")
	
	snake.queue_free()
