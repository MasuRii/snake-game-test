extends Node2D

@onready var game_state = get_node("/root/GameState")
@onready var snake: Node2D = $Snake
@onready var food: Node2D = $Food
@onready var timer: Timer = $GameTimer

const BASE_SPEED = 5.0
const SPEED_INCREMENT = 0.5
const SCORE_THRESHOLD = 50
const MAX_SPEED = 20.0
const SCORE_PER_FOOD = 10

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	game_state.score_updated.connect(_on_score_updated)

	game_state.set_state(game_state.State.MAIN_MENU)
	
	if not snake.collided_with_wall.is_connected(_on_snake_collided_with_wall):
		snake.collided_with_wall.connect(_on_snake_collided_with_wall)
	if not snake.collided_with_self.is_connected(_on_snake_collided_with_self):
		snake.collided_with_self.connect(_on_snake_collided_with_self)
	
	timer.timeout.connect(_on_game_timer_timeout)
	
	reset_game()

func reset_game() -> void:
	game_state.reset_score()
	_update_speed()
	
	# Reset snake and food
	if snake.has_method("reset"):
		snake.reset()
	
	if food.has_method("spawn") and snake.has_method("get_occupied_positions"):
		food.spawn(snake.get_occupied_positions())
	
	timer.start()

func _process(_delta: float) -> void:
	if game_state.current_state == game_state.State.PLAYING:
		if Input.is_action_just_pressed("pause"):
			_pause_game()
		elif snake.has_method("handle_input"):
			snake.handle_input()
	elif game_state.current_state == game_state.State.PAUSED:
		if Input.is_action_just_pressed("pause"):
			_resume_game()

func _on_game_timer_timeout() -> void:
	if game_state.current_state != game_state.State.PLAYING:
		return
	
	if snake.has_method("move"):
		snake.move()
	_check_collisions()

func _check_collisions() -> void:
	var snake_positions = snake.get_occupied_positions()
	if snake_positions.is_empty(): return
	
	var food_grid_pos = food.grid_position
	
	if snake_positions[0] == food_grid_pos:
		_handle_food_collision()

func _handle_food_collision() -> void:
	game_state.add_score(SCORE_PER_FOOD)
	if snake.has_method("grow"):
		snake.grow()
	if food.has_method("spawn"):
		food.spawn(snake.get_occupied_positions())

func _on_score_updated(_score: int) -> void:
	_update_speed()

func _update_speed() -> void:
	var speed = BASE_SPEED + (floor(game_state.current_score / SCORE_THRESHOLD) * SPEED_INCREMENT)
	speed = min(speed, MAX_SPEED)
	timer.wait_time = 1.0 / speed


func _pause_game() -> void:
	game_state.set_state(game_state.State.PAUSED)
	get_tree().paused = true

func _resume_game() -> void:
	game_state.set_state(game_state.State.PLAYING)
	get_tree().paused = false

func _on_snake_collided_with_wall() -> void:
	_game_over()

func _on_snake_collided_with_self() -> void:
	_game_over()

func _game_over() -> void:
	timer.stop()
	game_state.trigger_game_over()
