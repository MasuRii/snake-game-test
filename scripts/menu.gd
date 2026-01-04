extends Control

signal play_pressed
signal quit_pressed

@onready var game_state = get_node("/root/GameState")
@onready var play_button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton
@onready var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel

func _ready() -> void:
	play_button.pressed.connect(func(): play_pressed.emit())
	quit_button.pressed.connect(func(): quit_pressed.emit())
	_update_high_score(game_state.high_score)
	game_state.high_score_updated.connect(_update_high_score)

func _update_high_score(score: int) -> void:
	high_score_label.text = "High Score: " + str(score)
