extends Control

signal play_again_pressed
signal menu_pressed

@onready var score_label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var high_score_label = $CenterContainer/VBoxContainer/HighScoreLabel
@onready var play_again_button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton

func _ready() -> void:
	play_again_button.pressed.connect(func(): play_again_pressed.emit())
	menu_button.pressed.connect(func(): menu_pressed.emit())

func set_score(score: int, high_score: int) -> void:
	score_label.text = "Score: " + str(score)
	high_score_label.text = "High Score: " + str(high_score)
