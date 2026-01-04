extends Node

var suites: Array[Node] = []

func _ready() -> void:
	print("--- STARTING TEST RUNNER ---")
	
	# Add all suites here
	_add_suites()
	
	var total_passed = 0
	var total_failed = 0
	
	for suite in suites:
		print("\nSuite: ", suite.get_script().get_path().get_file())
		if suite.has_method("run_all_tests"):
			suite.run_all_tests()
			total_passed += suite.get("passed_count")
			total_failed += suite.get("failed_count")
	
	print("\n--- TEST RESULTS ---")
	print("Total Passed: ", total_passed)
	print("Total Failed: ", total_failed)
	var total = total_passed + total_failed
	print("Success Rate: ", (float(total_passed) / total * 100.0) if total > 0 else 0, "%")
	
	if total_failed > 0:
		print("SOME TESTS FAILED")
	else:
		print("ALL TESTS PASSED")
	
	# Wait a bit then quit if running in headless mode or as a script
	# Use a timer to allow for some async operations if needed
	await get_tree().create_timer(0.5).timeout
	
	if DisplayServer.get_name() == "headless" or OS.get_cmdline_args().has("--quit"):
		get_tree().quit(0 if total_failed == 0 else 1)

func _add_suites() -> void:
	# Unit Tests
	_add_suite("res://tests/unit/test_snake.gd")
	_add_suite("res://tests/unit/test_food.gd")
	_add_suite("res://tests/unit/test_game_state.gd")
	
	# Integration Tests
	_add_suite("res://tests/integration/test_game_flow.gd")
	_add_suite("res://tests/integration/test_persistence.gd")
	
	# Edge Cases
	_add_suite("res://tests/edge_cases/test_edge_cases.gd")
	
	# Performance
	_add_suite("res://tests/performance/test_performance.gd")

func _add_suite(path: String) -> void:
	if ResourceLoader.exists(path):
		var script = load(path)
		var suite = Node.new()
		suite.set_script(script)
		add_child(suite)
		suites.append(suite)
	else:
		print("Note: Test suite file not found yet: ", path)
