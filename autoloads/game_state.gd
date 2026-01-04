extends Node

enum State { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

signal score_updated(new_score: int)
signal high_score_updated(new_high_score: int)
signal state_changed(new_state: State)

var current_score: int = 0
var high_score: int = 0
var current_state: State = State.MAIN_MENU

const SAVE_PATH = "user://highscore.json"

func _ready() -> void:
	load_high_score()

func add_score(amount: int) -> void:
	current_score += amount
	score_updated.emit(current_score)
	if current_score > high_score:
		high_score = current_score
		high_score_updated.emit(high_score)
		save_high_score()

func reset_score() -> void:
	current_score = 0
	score_updated.emit(current_score)

func set_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)

func trigger_game_over() -> void:
	set_state(State.GAME_OVER)
	save_high_score()

func save_high_score() -> void:
	var data = {
		"high_score": high_score
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
	else:
		push_error("Failed to save high score to %s: %s" % [SAVE_PATH, FileAccess.get_open_error()])

func load_high_score() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.get_data()
			if data is Dictionary and data.has("high_score"):
				high_score = int(data["high_score"])
				high_score_updated.emit(high_score)
		else:
			push_error("Failed to parse high score file: %s at line %s" % [json.get_error_message(), json.get_error_line()])
	else:
		push_error("Failed to open high score file for reading: %s" % FileAccess.get_open_error())

func reset_high_score() -> void:
	high_score = 0
	high_score_updated.emit(high_score)
	save_high_score()
