extends "res://tests/test_suite.gd"

@onready var game_state = get_node("/root/GameState")

func test_score_increment() -> void:
	game_state.reset_score()
	assert_eq(game_state.current_score, 0)
	
	game_state.add_score(10)
	assert_eq(game_state.current_score, 10)
	assert_true(game_state.high_score >= 10, "High score should be at least 10")

func test_state_change() -> void:
	game_state.set_state(0) # MAIN_MENU
	assert_eq(game_state.current_state, 0)
	
	game_state.set_state(1) # PLAYING
	assert_eq(game_state.current_state, 1)

func test_high_score_persistence() -> void:
	game_state.high_score = 100
	game_state.save_high_score()
	
	game_state.high_score = 0
	game_state.load_high_score()
	assert_eq(game_state.high_score, 100, "High score should persist")
