extends "res://tests/test_suite.gd"

func test_frame_rate_simulation() -> void:
	var start_time = Time.get_ticks_usec()
	var iterations = 1000
	
	var snake = load("res://scenes/snake.tscn").instantiate()
	add_child(snake)
	
	for i in range(iterations):
		snake.move()
	
	var end_time = Time.get_ticks_usec()
	var total_time_ms = (end_time - start_time) / 1000.0
	var avg_time_per_move = total_time_ms / iterations
	
	print("Average move time: ", avg_time_per_move, "ms")
	assert_true(avg_time_per_move < 1.0, "Average move time should be well under 1ms for 60FPS target")
	
	snake.queue_free()

func test_memory_usage() -> void:
	var mem_before = OS.get_static_memory_usage()
	
	var nodes = []
	for i in range(100):
		var snake = load("res://scenes/snake.tscn").instantiate()
		add_child(snake)
		nodes.append(snake)
	
	var mem_after = OS.get_static_memory_usage()
	var diff_mb = (mem_after - mem_before) / 1024.0 / 1024.0
	
	print("Memory for 100 snakes: ", diff_mb, " MB")
	assert_true(diff_mb < 50, "Memory usage should be reasonable (100 snakes < 50MB)")
	
	for node in nodes:
		node.queue_free()

func test_load_time() -> void:
	var start_time = Time.get_ticks_msec()
	var main = load("res://scenes/main.tscn").instantiate()
	var end_time = Time.get_ticks_msec()
	
	var load_time = end_time - start_time
	print("Main scene load time: ", load_time, "ms")
	assert_true(load_time < 2000, "Load time should be under 2 seconds")
	
	main.queue_free()
