extends "res://tests/test_suite.gd"

@onready var game_state = get_node("/root/GameState")

func test_high_score_saving_loading() -> void:
	# 1. Reset
	game_state.high_score = 0
	game_state.current_score = 0
	game_state.save_high_score()
	
	# 2. Update
	game_state.add_score(150)
	assert_eq(game_state.high_score, 150)
	
	# 3. Reload from fresh
	game_state.high_score = 0
	game_state.load_high_score()
	assert_eq(game_state.high_score, 150, "Score should be 150 after reload")

func test_corrupted_save_file() -> void:
	# Write garbage to save file
	var file = FileAccess.open(game_state.SAVE_PATH, FileAccess.WRITE)
	file.store_string("THIS IS NOT JSON")
	file.close()
	
	# Should not crash and handle gracefully (stay at 0 or previous)
	game_state.high_score = 0
	game_state.load_high_score()
	assert_eq(game_state.high_score, 0, "Should handle corrupted file gracefully")
