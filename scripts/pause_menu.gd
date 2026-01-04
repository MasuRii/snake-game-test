extends Control

signal resume_pressed
signal restart_pressed
signal menu_pressed

@onready var resume_button = $CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button = $CenterContainer/VBoxContainer/RestartButton
@onready var menu_button = $CenterContainer/VBoxContainer/MenuButton

func _ready() -> void:
	resume_button.pressed.connect(func(): resume_pressed.emit())
	restart_button.pressed.connect(func(): restart_pressed.emit())
	menu_button.pressed.connect(func(): menu_pressed.emit())
