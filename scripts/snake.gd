extends Node2D

class_name Snake

const TILE_SIZE = 32
const GRID_WIDTH = 20
const GRID_HEIGHT = 20

const INITIAL_POS = Vector2i(10, 10)
const INITIAL_LENGTH = 3

signal collided_with_wall
signal collided_with_self

var direction: Vector2i = Vector2i.RIGHT
var input_queue: Array[Vector2i] = []
var positions: Array[Vector2i] = []
var body_segments: Array[Node2D] = []

@export var head_scene: PackedScene
@export var segment_scene: PackedScene

func _ready() -> void:
	reset()

func reset() -> void:
	_clear_snake()
	_initialize_snake()

func _clear_snake() -> void:
	for segment in body_segments:
		segment.queue_free()
	body_segments.clear()
	positions.clear()
	input_queue.clear()

func _initialize_snake() -> void:
	direction = Vector2i.RIGHT
	
	for i in range(INITIAL_LENGTH):
		var pos = INITIAL_POS - direction * i
		positions.append(pos)
		
		var segment
		if i == 0:
			segment = head_scene.instantiate()
		else:
			segment = segment_scene.instantiate()
		
		add_child(segment)
		segment.position = Vector2(pos * TILE_SIZE)
		body_segments.append(segment)

func handle_input() -> void:
	if Input.is_action_just_pressed("move_up"):
		_queue_direction(Vector2i.UP)
	elif Input.is_action_just_pressed("move_down"):
		_queue_direction(Vector2i.DOWN)
	elif Input.is_action_just_pressed("move_left"):
		_queue_direction(Vector2i.LEFT)
	elif Input.is_action_just_pressed("move_right"):
		_queue_direction(Vector2i.RIGHT)

func _queue_direction(new_dir: Vector2i) -> void:
	if input_queue.size() < 2:
		var last_dir = direction
		if not input_queue.is_empty():
			last_dir = input_queue.back()
		
		# Prevent 180 degree turns
		if new_dir != -last_dir:
			input_queue.append(new_dir)

func move() -> void:
	_update_direction_from_queue()
	
	var new_head_pos = positions[0] + direction
	
	if _check_wall_collision(new_head_pos):
		collided_with_wall.emit()
		return
	
	if _check_self_collision(new_head_pos):
		collided_with_self.emit()
		return
	
	_update_positions(new_head_pos)
	_update_visuals()

func _update_direction_from_queue() -> void:
	if not input_queue.is_empty():
		direction = input_queue.pop_front()

func _check_wall_collision(pos: Vector2i) -> bool:
	return pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT

func _check_self_collision(pos: Vector2i) -> bool:
	# Check collision ignoring the tail position as it will move
	return pos in positions.slice(0, -1)

func _update_positions(new_head_pos: Vector2i) -> void:
	positions.insert(0, new_head_pos)
	positions.pop_back()

func _update_visuals() -> void:
	for i in range(body_segments.size()):
		body_segments[i].position = Vector2(positions[i] * TILE_SIZE)

func grow() -> void:
	var last_pos = positions.back()
	# For growth, we add a position that will be updated on next move
	# but for now we just duplicate the last one
	positions.append(last_pos)
	
	var segment = segment_scene.instantiate()
	add_child(segment)
	segment.position = Vector2(last_pos * TILE_SIZE)
	body_segments.append(segment)

func get_occupied_positions() -> Array[Vector2i]:
	return positions
