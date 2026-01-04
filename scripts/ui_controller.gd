extends Control

@onready var game_state = get_node("/root/GameState")
@onready var main_menu = $MainMenu
@onready var hud = $HUD
@onready var pause_menu = $PauseMenu
@onready var game_over = $GameOver

func _ready() -> void:
	game_state.state_changed.connect(_on_state_changed)
	game_state.score_updated.connect(_on_score_updated)
	
	# Connect signals from UI components
	main_menu.play_pressed.connect(_on_play_pressed)
	main_menu.quit_pressed.connect(_on_quit_pressed)
	
	pause_menu.resume_pressed.connect(_on_resume_pressed)
	pause_menu.restart_pressed.connect(_on_restart_pressed)
	pause_menu.menu_pressed.connect(_on_menu_pressed)
	
	game_over.play_again_pressed.connect(_on_play_pressed)
	game_over.menu_pressed.connect(_on_menu_pressed)
	
	_update_ui(game_state.current_state)

func _on_state_changed(new_state: int) -> void:
	_update_ui(new_state)

func _update_ui(state: int) -> void:
	main_menu.visible = (state == game_state.State.MAIN_MENU)
	hud.visible = (state == game_state.State.PLAYING or state == game_state.State.PAUSED)
	pause_menu.visible = (state == game_state.State.PAUSED)
	game_over.visible = (state == game_state.State.GAME_OVER)
	
	if state == game_state.State.GAME_OVER:
		game_over.set_score(game_state.current_score, game_state.high_score)

func _on_score_updated(score: int) -> void:
	hud.update_score(score)

func _start_game() -> void:
	if owner and owner.has_method("reset_game"):
		owner.reset_game()
	game_state.set_state(game_state.State.PLAYING)
	get_tree().paused = false

func _on_play_pressed() -> void:
	_start_game()

func _on_resume_pressed() -> void:
	game_state.set_state(game_state.State.PLAYING)
	get_tree().paused = false

func _on_restart_pressed() -> void:
	_start_game()

func _on_menu_pressed() -> void:
	game_state.set_state(game_state.State.MAIN_MENU)
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().quit()
