extends Control

@onready var game_state = get_node("/root/GameState")
@onready var score_label = $MarginContainer/HBoxContainer/ScoreValue
@onready var high_score_label = $MarginContainer/HBoxContainer/HighScoreValue

func _ready() -> void:
	update_score(game_state.current_score)
	update_high_score(game_state.high_score)
	game_state.high_score_updated.connect(update_high_score)

func update_score(score: int) -> void:
	score_label.text = str(score)

func update_high_score(score: int) -> void:
	high_score_label.text = str(score)
