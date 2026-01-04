# Snake Game Architecture Plan

**Agent**: @architect  
**Date**: 2026-01-04  
**Version**: v1.0  
**Project**: Snake Game Clone (Godot 4.5.1)  
**Status**: Ready for Implementation  
**Parent Document**: `docs/specs/PRODUCT_SPEC_SNAKE_GAME.md`

---

## 1. Executive Summary

This architecture plan defines the complete technical design for the Snake game implementation in Godot 4.5.1. The design prioritizes performance, maintainability, and testability while adhering to Godot 4.x best practices. Key architectural decisions include timer-based grid movement for consistent gameplay, Area2D-based collision detection for food and wall detection, and signal-driven communication patterns for loose coupling between components. The architecture separates concerns across autoload singletons, scene-specific controllers, and entity scripts to enable independent testing and modification of game components.

The architecture follows a hierarchical scene structure where the main game scene orchestrates gameplay while delegating specific responsibilities to specialized child nodes and autoload singletons. Input handling uses Godot's Input Map system for configurable controls with WASD and arrow key support. Score persistence is implemented through JSON file storage with automatic high score tracking. The design supports all product requirements including progressive difficulty, pause functionality, and multiple game states while maintaining 60 FPS performance targets.

---

## 2. Architecture Principles and Design Guidelines

### 2.1 Core Design Principles

The architecture adheres to Godot 4.5.1 best practices and software engineering principles to ensure code quality and maintainability. Single Responsibility Principle guides the separation of concerns, with each script handling one specific domain of functionality such as snake movement, food spawning, or score management. Interface Segregation is achieved through Godot's signal system, allowing components to communicate without direct dependencies, making it easier to modify or replace individual components without affecting others. The KISS principle (Keep It Simple, Stupid) is applied throughout, favoring straightforward grid-based mechanics over complex physics simulations.

Type safety is enforced through Godot 4.x's static typing capabilities, with all variables and parameters declared with explicit types to catch errors at compile time and improve IDE support. Resource organization follows Godot's conventions, with scenes and scripts grouped logically by their functional domain. Node naming conventions use PascalCase for classes and snake_case for variables and functions, aligning with Godot's established patterns and making code easier to read and navigate.

### 2.2 Performance Considerations

Performance optimization begins at the architectural level by choosing efficient collision detection mechanisms. For the snake game, coordinate-based collision checking is preferred over Area2D for wall and self-collision because it requires only simple integer comparisons rather than physics engine overhead. Food collision uses Area2D signals for simplicity and extensibility, but the area is configured with minimal physics layers to reduce computational cost.

Memory management is addressed through object pooling concepts where feasible, particularly for frequently created and destroyed objects like food items. The snake body segments use a fixed array-based data structure rather than dynamic linked lists to ensure cache-friendly access patterns. The architecture minimizes garbage collection pressure by reusing node instances and avoiding unnecessary object creation during gameplay.

The timer-based movement system provides predictable performance characteristics by decoupling input processing from movement execution. Input is queued and processed at fixed intervals, eliminating variable-frame-rate behaviors that could cause inconsistent gameplay. This design ensures the game maintains 60 FPS even on lower-end hardware while providing the responsive input handling required by the product specification.

---

## 3. Scene Structure and Node Hierarchy

### 3.1 Main Scene Architecture

The main scene serves as the game orchestrator, managing the overall game lifecycle and coordinating between child components. The scene tree structure follows a clear hierarchy that reflects data flow and responsibility boundaries.

```
main.tscn (Node2D)
├── game_manager.gd (Node)
├── game_grid (Node2D) - Grid boundary visualization and management
├── snake_head.tscn (CharacterBody2D) - Player-controlled snake head
├── food.tscn (Area2D) - Current food item
├── canvas_layer (CanvasLayer)
│   └── ui.tscn (Control)
│       ├── main_menu.tscn (Panel)
│       ├── hud.tscn (Control)
│       ├── pause_menu.tscn (Panel)
│       └── game_over.tscn (Panel)
├── game_timer (Timer) - Game tick timer
└── difficulty_timer (Timer) - Difficulty scaling timer
```

The game_manager.gd node serves as the primary controller for the main scene, managing game state transitions, coordinating between components, and handling global game events. This node maintains references to all child nodes and communicates with them through a combination of direct method calls for tightly coupled operations and signals for event-based communication.

The canvas_layer ensures UI elements remain fixed on screen regardless of camera movement or scaling, which is essential for consistent UI presentation. Each UI panel (main_menu, hud, pause_menu, game_over) is designed as a self-contained scene that manages its own internal logic and state while communicating with the game_manager through well-defined interfaces.

### 3.2 Snake Scene Architecture

The snake is implemented as two separate scenes to optimize performance and simplify collision handling. The head and body have different behavioral requirements that are best served by different node types and configurations.

**snake_head.tscn (CharacterBody2D)**:
```
snake_head (CharacterBody2D)
├── collision_shape (CollisionShape2D) - 32x32 rectangle
├── sprite (Sprite2D) - Head sprite
├── direction_label (Label) - Optional debug display
└── snake_body_container (Node) - Parent node for body segments
```

The CharacterBody2D node type is chosen for the snake head because it provides built-in collision detection capabilities while remaining lightweight. The head's collision shape is configured to interact only with the food Area2D and boundary colliders, not with the snake's own body segments, preventing self-collision issues during movement.

**snake_body.tscn (Node2D)**:
```
snake_body (Node2D)
├── sprite (Sprite2D) - Body segment sprite
└── collision_area (Area2D) - Optional: for advanced collision detection
```

Body segments use the simpler Node2D type since they do not require physics-based movement or collision response. They follow the head's position through a history-based trailing system where each segment occupies the position previously held by the segment ahead of it. This approach eliminates complex inverse kinematics and provides smooth, predictable movement.

### 3.3 Food Scene Architecture

**food.tscn (Area2D)**:
```
food (Area2D)
├── collision_shape (CollisionShape2D) - 32x32 circle or rectangle
└── sprite (Sprite2D) - Food sprite with animation support
```

The Area2D type is selected for the food item because it provides signal-based collision detection that integrates cleanly with the snake head's collision handling. The food item emits a body_entered signal when the snake head enters its area, triggering the consumption logic without requiring continuous polling or manual collision checks.

The food scene includes animation support for visual feedback when the food is consumed, including a shrink animation or particle effect. The sprite node is configured with appropriate texture settings for pixel-perfect rendering at the game's designated resolution.

### 3.4 UI Scene Architecture

Each UI component follows a consistent internal structure that promotes reusability and maintainability while providing clear visual hierarchy and keyboard navigation support.

**main_menu.tscn (Control)**:
```
main_menu (Control) - Full-screen container
├── background (ColorRect) - Semi-transparent background
├── panel (PanelContainer) - Menu container
│   └── vbox (VBoxContainer)
│       ├── title (Label) - Game title
│       ├── start_button (Button) - "Start Game"
│       ├── continue_button (Button) - "Continue" (disabled if no saved game)
│       ├── settings_button (Button) - "Settings"
│       └── quit_button (Button) - "Quit"
└── high_score_label (Label) - Current high score display
```

**hud.tscn (Control)**:
```
hud (Control) - Full-screen UI layer
├── score_container (HBoxContainer)
│   ├── score_label (Label) - "Score: "
│   └── score_value (Label) - Current score
└── high_score_container (HBoxContainer)
    ├── high_score_label (Label) - "High Score: "
    └── high_score_value (Label) - Stored high score
```

**pause_menu.tscn (Control)**:
```
pause_menu (Control) - Full-screen overlay
├── background (ColorRect) - Dimmed background
├── panel (PanelContainer)
│   └── vbox (VBoxContainer)
│       ├── title (Label) - "Paused"
│       ├── resume_button (Button) - "Resume"
│       ├── restart_button (Button) - "Restart"
│       └── menu_button (Button) - "Main Menu"
```

**game_over.tscn (Control)**:
```
game_over (Control) - Full-screen overlay
├── background (ColorRect) - Semi-transparent dark background
├── panel (PanelContainer)
│   └── vbox (VBoxContainer)
│       ├── title (Label) - "Game Over"
│       ├── final_score_label (Label) - "Final Score: "
│       ├── final_score_value (Label) - Score number
│       ├── new_high_score_label (Label) - "New High Score!" (hidden by default)
│       ├── play_again_button (Button) - "Play Again"
│       └── menu_button (Button) - "Main Menu"
└── high_score_display (Label) - Current high score
```

---

## 4. Class Hierarchy and Responsibilities

### 4.1 Core Game Classes

The class hierarchy is organized to maximize cohesion within classes and minimize coupling between them. Each class has clearly defined responsibilities and communicates with other classes through well-defined interfaces.

#### 4.1.1 GameState (Autoload Singleton)

**File**: `autoloads/game_state.gd`  
**Type**: Node (Autoloaded as "GameState")  
**Purpose**: Global game state management and cross-scene data persistence

The GameState autoload serves as the central repository for game-wide data and state transitions. It persists across scene changes and provides a single source of truth for the current game state, scores, and settings. This singleton implements the singleton pattern using Godot's autoload system, ensuring exactly one instance exists throughout the game lifecycle.

**Responsibilities**:
- Manage current game state enum (MAIN_MENU, PLAYING, PAUSED, GAME_OVER)
- Track and persist current score and high score
- Manage game settings (volume levels, difficulty parameters)
- Provide event bus signals for game-wide communication
- Handle score file I/O with JSON serialization
- Coordinate state transitions and notify listening components

**Key Methods and Properties**:
```gdscript
# State Management
var current_state: GameStateEnum = GameStateEnum.MAIN_MENU
func set_game_state(new_state: GameStateEnum) -> void

# Score Management
var current_score: int = 0
var high_score: int = 0
func add_score(points: int) -> void
func reset_score() -> void
func save_high_score() -> void
func load_high_score() -> void

# Settings Management
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var base_game_speed: float = 5.0  # tiles per second

# Event Bus Signals
signal state_changed(old_state: GameStateEnum, new_state: GameStateEnum)
signal score_updated(new_score: int)
signal game_paused()
signal game_resumed()
signal game_over(final_score: int)
signal food_consumed()
```

**Score Persistence Implementation**:
The GameState class implements high score persistence using JSON file storage in the user's application data directory. The implementation includes error handling for file I/O failures and gracefully falls back to default values if the save file is corrupted or missing.

```gdscript
const SCORE_FILE_PATH = "user://snake_game_highscore.json"

func load_high_score() -> void:
    var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_string)
        if error == OK:
            high_score = json.data.get("high_score", 0)
        file.close()
    else:
        high_score = 0

func save_high_score() -> void:
    var json = JSON.new()
    json.data = {"high_score": high_score, "timestamp": Time.get_unix_time_from_system()}
    var file = FileAccess.open(SCORE_FILE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(json.stringify())
        file.close()
```

#### 4.1.2 GameManager

**File**: `scripts/main/game_manager.gd`  
**Type**: Node (Child of main.tscn)  
**Purpose**: Main scene orchestration and game loop management

The GameManager class controls the main game scene, coordinating between the snake, food, UI, and game state. It implements the game loop through a timer-based tick system and handles state transitions by responding to both user input and game events.

**Responsibilities**:
- Initialize and coordinate all game components
- Manage the game tick timer and movement scheduling
- Handle collision detection results
- Coordinate difficulty scaling based on score
- Manage pause and resume functionality
- Communicate with UI components through signals

**Key Methods and Properties**:
```gdscript
# Node References
@onready var snake_head: CharacterBody2D = $snake_head
@onready var food: Area2D = $food
@onready var game_timer: Timer = $game_timer
@onready var game_state = GameState

# Game Configuration
const GRID_SIZE: int = 32
const GRID_WIDTH: int = 20
const GRID_HEIGHT: int = 20
const INITIAL_SPEED: float = 5.0  # tiles per second
const SPEED_INCREMENT: float = 0.5
const SCORE_PER_FOOD: int = 10
const SPEED_INCREASE_THRESHOLD: int = 50

# Lifecycle Methods
func _ready() -> void:
    setup_connections()
    game_state.load_high_score()
    show_main_menu()

func _physics_process(delta: float) -> void:
    process_input_queue()

func _on_game_timer_timeout() -> void:
    process_game_tick()

# State Management
func start_game() -> void
func pause_game() -> void
func resume_game() -> void
func end_game() -> void
func reset_game() -> void

# Difficulty Management
func update_game_speed() -> void
func calculate_target_speed() -> float
```

#### 4.1.3 SnakeController

**File**: `scripts/snake/snake_controller.gd`  
**Type**: CharacterBody2D (snake_head.tscn root)  
**Purpose**: Snake movement, direction management, and growth logic

The SnakeController class implements the snake's movement system using a grid-based approach with input queuing. It maintains an array of body segment positions and handles the logic for growing the snake when food is consumed.

**Responsibilities**:
- Manage current movement direction and next direction queue
- Execute grid-based movement on game ticks
- Track and position snake body segments
- Detect self-collision through position history
- Communicate with GameManager for collision events
- Handle growth when food is consumed

**Key Methods and Properties**:
```gdscript
# Direction Enum
enum Direction { UP, DOWN, LEFT, RIGHT }

# Movement State
var current_direction: Direction = Direction.RIGHT
var next_direction: Direction = Direction.RIGHT
var direction_queue: Array[Direction] = []

# Body Management
var body_segments: Array[Node2D] = []
var segment_scene: PackedScene = preload("res://scenes/snake_body.tscn")
const BODY_SPACING: int = 32  # pixels, matches grid size

# Position History for trailing segments
var position_history: Array[Vector2i] = []

# Movement Methods
func queue_direction(new_direction: Direction) -> void
func move() -> Vector2i
func grow() -> void
func shrink() -> void

# Direction Validation
func is_valid_direction(new_direction: Direction) -> bool
func get_opposite_direction(dir: Direction) -> Direction

# Position Tracking
func get_current_grid_position() -> Vector2i
func get_segment_world_position(index: int) -> Vector2
```

**Movement Implementation**:
The snake uses a position history system to create smooth body movement. Each game tick, the head moves to a new position while storing its old position. Body segments occupy positions from the history, with each segment lagging behind the one ahead of it.

```gdscript
func move() -> Vector2i:
    # Process direction queue for this tick
    while not direction_queue.is_empty():
        var queued_dir = direction_queue.pop_front()
        if is_valid_direction(queued_dir):
            current_direction = queued_dir
            break
    
    # Calculate new head position
    var current_pos = get_current_grid_position()
    var new_pos = current_pos + direction_to_vector(current_direction)
    
    # Store position in history
    position_history.push_front(current_pos)
    
    # Update actual position
    global_position = Vector2(new_pos.x * GRID_SIZE, new_pos.y * GRID_SIZE)
    
    # Trim history to segment count
    while position_history.size() > body_segments.size() + 1:
        position_history.pop_back()
    
    return new_pos

func queue_direction(new_direction: Direction) -> void:
    # Prevent 180-degree turns and rapid direction changes
    if direction_queue.size() >= MAX_QUEUE_SIZE:
        return
    if direction_queue.is_empty():
        if is_valid_direction(new_direction):
            direction_queue.append(new_direction)
    else:
        var last_queued = direction_queue.back()
        if last_queued != new_direction and last_queued != get_opposite_direction(new_direction):
            direction_queue.append(new_direction)
```

#### 4.1.4 FoodController

**File**: `scripts/food/food_controller.gd`  
**Type**: Area2D (food.tscn root)  
**Purpose**: Food spawning logic and consumption handling

The FoodController class manages the food item's behavior, including random spawning at valid grid positions and signaling consumption events to the game manager.

**Responsibilities**:
- Spawn food at random valid grid positions
- Validate spawn positions against snake body occupancy
- Animate consumption feedback
- Communicate consumption events to game manager

**Key Methods and Properties**:
```gdscript
# Node References
@onready var sprite: Sprite2D = $sprite
@onready var collision_shape: CollisionShape2D = $collision_shape

# Spawning Methods
func spawn_valid_position(occupied_positions: Array[Vector2i], grid_bounds: Rect2i) -> Vector2i
func move_to_position(grid_pos: Vector2i) -> void
func is_valid_spawn(grid_pos: Vector2i, occupied_positions: Array[Vector2i]) -> bool

# Consumption Methods
func consume() -> void
func play_consumption_animation() -> void

# Properties
var current_grid_position: Vector2i
```

**Spawn Validation Logic**:
The food controller implements intelligent spawning that avoids placing food on the snake's body or outside the game grid. It includes retry logic to handle crowded boards where valid spawn positions may be limited.

```gdscript
func spawn_valid_position(occupied_positions: Array[Vector2i], grid_bounds: Rect2i) -> Vector2i:
    var max_attempts = 100
    var attempt = 0
    
    while attempt < max_attempts:
        var random_pos = Vector2i(
            randi_range(grid_bounds.position.x, grid_bounds.end.x - 1),
            randi_range(grid_bounds.position.y, grid_bounds.end.y - 1)
        )
        
        if is_valid_spawn(random_pos, occupied_positions):
            move_to_position(random_pos)
            return random_pos
        
        attempt += 1
    
    # Fallback: find first valid position
    for x in range(grid_bounds.position.x, grid_bounds.end.x):
        for y in range(grid_bounds.position.y, grid_bounds.end.y):
            var pos = Vector2i(x, y)
            if is_valid_spawn(pos, occupied_positions):
                move_to_position(pos)
                return pos
    
    return Vector2i(-1, -1)  # No valid position found

func is_valid_spawn(grid_pos: Vector2i, occupied_positions: Array[Vector2i]) -> bool:
    if not grid_bounds.has_point(Vector2(grid_pos.x, grid_pos.y)):
        return false
    
    for occupied in occupied_positions:
        if grid_pos == occupied:
            return false
    
    return true
```

### 4.2 UI Controller Classes

#### 4.2.1 UIController

**File**: `scripts/ui/ui_controller.gd`  
**Type**: Control (ui.tscn root)  
**Purpose**: Central UI management and scene switching

The UIController class manages the visibility and behavior of all UI components, coordinating transitions between different screens and handling user interactions with UI elements.

**Responsibilities**:
- Show and hide UI panels based on game state
- Update score displays in real-time
- Handle button press signals from all UI elements
- Manage UI-related animations and transitions
- Provide keyboard navigation support

**Key Methods and Properties**:
```gdscript
# Node References
@onready var main_menu: Control = $main_menu
@onready var hud: Control = $hud
@onready var pause_menu: Control = $pause_menu
@onready var game_over: Control = $game_over

# UI State
var current_ui_state: UIState = UIState.MAIN_MENU

# Display Management
func show_main_menu() -> void
func show_hud() -> void
func show_pause_menu() -> void
func show_game_over() -> void
func hide_all_panels() -> void

# Score Display
func update_score_display(current_score: int, high_score: int) -> void
func animate_score_change(label: Label) -> void

# Button Connections
func connect_menu_buttons() -> void
func connect_hud_buttons() -> void
func connect_pause_buttons() -> void
func connect_game_over_buttons() -> void
```

#### 4.2.2 MainMenuController

**File**: `scripts/ui/main_menu_controller.gd`  
**Type**: Control (main_menu.tscn root)  
**Purpose**: Main menu screen logic and user interaction

The MainMenuController handles the specific behavior of the main menu screen, including button interactions and high score display.

**Key Methods**:
```gdscript
func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    settings_button.pressed.connect(_on_settings_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    update_high_score_display()

func update_high_score_display() -> void:
    high_score_label.text = "High Score: %d" % GameState.high_score

func _on_start_pressed() -> void:
    get_tree().call_group("game_manager", "start_game")
```

#### 4.2.3 GameOverController

**File**: `scripts/ui/game_over_controller.gd`  
**Type**: Control (game_over.tscn root)  
**Purpose**: Game over screen logic and score display

The GameOverController manages the game over screen, displaying final scores and providing navigation options.

**Key Methods**:
```gdscript
func setup(final_score: int, is_new_high_score: bool) -> void:
    final_score_value.text = str(final_score)
    new_high_score_label.visible = is_new_high_score
    play_again_button.pressed.connect(_on_play_again_pressed)
    menu_button.pressed.connect(_on_menu_pressed)

func _on_play_again_pressed() -> void:
    get_tree().call_group("game_manager", "reset_game")

func _on_menu_pressed() -> void:
    get_tree().call_group("game_manager", "show_main_menu")
```

### 4.3 Utility Classes

#### 4.3.1 GridUtils

**File**: `scripts/utils/grid_utils.gd`  
**Type**: Script (Not a node, used as static class)  
**Purpose**: Grid-related utility functions

This static utility class provides common grid operations used throughout the game, reducing code duplication and centralizing grid logic.

```gdscript
class_name GridUtils

static func world_to_grid(world_pos: Vector2, grid_size: int) -> Vector2i:
    return Vector2i(
        int(world_pos.x / grid_size),
        int(world_pos.y / grid_size)
    )

static func grid_to_world(grid_pos: Vector2i, grid_size: int) -> Vector2:
    return Vector2(grid_pos.x * grid_size, grid_pos.y * grid_size)

static func direction_to_vector(direction: int) -> Vector2i:
    match direction:
        Direction.UP: return Vector2i(0, -1)
        Direction.DOWN: return Vector2i(0, 1)
        Direction.LEFT: return Vector2i(-1, 0)
        Direction.RIGHT: return Vector2i(1, 0)
        _: return Vector2i(0, 0)

static func get_opposite_direction(direction: int) -> int:
    match direction:
        Direction.UP: return Direction.DOWN
        Direction.DOWN: return Direction.UP
        Direction.LEFT: return Direction.RIGHT
        Direction.RIGHT: return Direction.LEFT
        _: return direction
```

---

## 5. Autoload Singleton Specifications

### 5.1 GameState Implementation Details

The GameState autoload is the single most important architectural decision for maintaining clean separation between game components. It serves as both a data container and an event bus, enabling loose coupling between components that need to share information without direct references.

**Autoload Registration**:
The GameState script is registered in Godot's autoload configuration at project level:
- Autoload Name: `GameState`
- Path: `res://autoloads/game_state.gd`
- This makes it accessible from any script via the global `GameState` variable

**Signal-Based Communication**:
All state changes and important events are broadcast through signals, allowing components to react to changes without polling or direct coupling:

```gdscript
# Signal definitions in GameState
signal state_changed(old_state: GameStateEnum, new_state: GameStateEnum)
signal score_updated(new_score: int)
signal game_paused()
signal game_resumed()
signal game_over(final_score: int)
signal food_consumed()
signal high_score_updated(new_high_score: int)

# Example usage in other scripts
func _ready() -> void:
    GameState.score_updated.connect(_on_score_updated)

func _on_score_updated(new_score: int) -> void:
    ui_controller.update_score_display(new_score, GameState.high_score)
```

**State Machine Implementation**:
The GameState implements a simple state machine with defined transitions:

```gdscript
enum GameStateEnum { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameStateEnum = GameStateEnum.MAIN_MENU

func set_game_state(new_state: GameStateEnum) -> void:
    if current_state == new_state:
        return
    
    var old_state = current_state
    current_state = new_state
    
    # Validate state transition
    if not is_valid_transition(old_state, new_state):
        push_error("Invalid state transition: %s -> %s" % [old_state, new_state])
        return
    
    state_changed.emit(old_state, new_state)
    handle_state_entry(new_state)

func is_valid_transition(from: GameStateEnum, to: GameStateEnum) -> bool:
    var valid_transitions = {
        GameStateEnum.MAIN_MENU: [GameStateEnum.PLAYING],
        GameStateEnum.PLAYING: [GameStateEnum.PAUSED, GameStateEnum.GAME_OVER],
        GameStateEnum.PAUSED: [GameStateEnum.PLAYING, GameStateEnum.MAIN_MENU],
        GameStateEnum.GAME_OVER: [GameStateEnum.MAIN_MENU, GameStateEnum.PLAYING]
    }
    return to in valid_transitions.get(from, [])
```

### 5.2 Configuration and Settings Management

The GameState singleton also manages game configuration that needs to persist across sessions:

```gdscript
class_name GameState extends Node

# Settings with defaults
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var base_game_speed: float = 5.0
var speed_increment: float = 0.5
var score_per_food: int = 10
var speed_increase_threshold: int = 50

# Settings file path
const SETTINGS_FILE_PATH = "user://snake_game_settings.json"

func save_settings() -> void:
    var json = JSON.new()
    json.data = {
        "music_volume": music_volume,
        "sfx_volume": sfx_volume,
        "base_game_speed": base_game_speed
    }
    var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(json.stringify())

func load_settings() -> void:
    var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        var json = JSON.new()
        if json.parse(json_string) == OK:
            music_volume = json.data.get("music_volume", 1.0)
            sfx_volume = json.data.get("sfx_volume", 1.0)
            base_game_speed = json.data.get("base_game_speed", 5.0)
```

---

## 6. Input Map Configuration

### 6.1 Input Actions Specification

The Input Map configuration defines all player controls in a centralized location, making it easy to modify controls without searching through code. The following input actions are defined in Project Settings → Input Map:

| Action Name | Primary Binding | Secondary Binding | Purpose |
|-------------|-----------------|-------------------|---------|
| `move_up` | Up Arrow (key) | W (key) | Move snake upward |
| `move_down` | Down Arrow (key) | S (key) | Move snake downward |
| `move_left` | Left Arrow (key) | A (key) | Move snake leftward |
| `move_right` | Right Arrow (key) | D (key) | Move snake rightward |
| `pause` | Escape (key) | P (key) | Toggle pause state |
| `ui_accept` | Enter (key) | Space (key) | UI button confirmation |
| `ui_cancel` | Escape (key) | Backspace (key) | UI cancellation |
| `ui_focus_next` | Tab (key) | - | Keyboard navigation |
| `ui_focus_prev` | Shift + Tab (key) | - | Reverse keyboard navigation |

### 6.2 Input Handling Implementation

Input is handled in the GameManager script using Godot's Input singleton, providing low-latency response times that meet the 50ms requirement:

```gdscript
func _process(delta: float) -> void:
    if GameState.current_state != GameStateEnum.PLAYING:
        return
    
    # Handle pause toggle
    if Input.is_action_just_pressed("pause"):
        if GameState.current_state == GameStateEnum.PLAYING:
            pause_game()
        elif GameState.current_state == GameStateEnum.PAUSED:
            resume_game()
        return
    
    # Queue direction changes
    if Input.is_action_just_pressed("move_up"):
        snake_head.queue_direction(SnakeController.Direction.UP)
    elif Input.is_action_just_pressed("move_down"):
        snake_head.queue_direction(SnakeController.Direction.DOWN)
    elif Input.is_action_just_pressed("move_left"):
        snake_head.queue_direction(SnakeController.Direction.LEFT)
    elif Input.is_action_just_pressed("move_right"):
        snake_head.queue_direction(SnakeController.Direction.RIGHT)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        if GameState.current_state == GameStateEnum.PLAYING:
            pause_game()
```

### 6.3 Input Queue for Rapid Direction Changes

The input queue system prevents multiple direction changes within a single game tick and eliminates the possibility of 180-degree turns:

```gdscript
const MAX_QUEUE_SIZE: int = 2  # Prevent excessive queuing

func queue_direction(new_direction: Direction) -> void:
    # Don't queue if game is not in playing state
    if GameState.current_state != GameStateEnum.PLAYING:
        return
    
    # Don't queue if already queued maximum
    if direction_queue.size() >= MAX_QUEUE_SIZE:
        return
    
    # Don't queue if same as current direction
    if new_direction == current_direction:
        return
    
    # Don't queue 180-degree turns
    var last_direction = direction_queue.back() if not direction_queue.is_empty() else current_direction
    if new_direction == get_opposite_direction(last_direction):
        return
    
    direction_queue.append(new_direction)
```

---

## 7. Communication Patterns and Data Flow

### 7.1 Signal Communication Architecture

The architecture employs a hybrid communication model that uses signals for event-based communication and direct method calls for tightly coupled operations. This approach balances flexibility with performance.

**Signal Flow Diagram**:
```
┌─────────────────────────────────────────────────────────────────┐
│                        GAME LOOP FLOW                            │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐         ┌──────────────┐
    │   Input      │         │  Game Timer  │
    │  (Keyboard)  │         │   (Tick)     │
    └──────┬───────┘         └──────┬───────┘
           │                        │
           ▼                        ▼
    ┌──────────────────────────────────────────┐
    │           GameManager                    │
    │  - Processes input queue                 │
    │  - Coordinates game tick                 │
    │  - Manages game state                    │
    └────────────────┬─────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐  ┌──────────┐  ┌─────────┐
   │  Snake  │  │   Food   │  │   UI    │
   │ Controller│  │Controller│  │ Controller
   └────┬────┘  └────┬─────┘  └────┬────┘
        │            │             │
        ▼            ▼             │
   ┌──────────────────────────────────────────┐
    │              GameState                   │
    │  - Score management                      │
    │  - State persistence                     │
    │  - Event broadcasting                    │
    └────────────────┬─────────────────────────┘
                     │
                     ▼ (Signal Broadcast)
           ┌─────────────────────┐
           │   All Subscribers   │
           │   (UI, Audio, etc.) │
           └─────────────────────┘
```

**Key Signal Connections**:

```gdscript
# In GameManager._ready()
func setup_connections() -> void:
    # Food consumption signal
    food.body_entered.connect(_on_food_consumed)
    
    # Snake collision signal (for walls and self-collision)
    snake_head.wall_collision.connect(_on_wall_collision)
    snake_head.self_collision.connect(_on_self_collision)
    
    # GameState signals
    GameState.state_changed.connect(_on_game_state_changed)
    
    # UI button signals (connected via UI scene scripts)

# Food consumption handler
func _on_food_consumed(body: Node) -> void:
    if body == snake_head:
        var new_score = GameState.add_score(GameState.score_per_food)
        snake_head.grow()
        food.spawn_valid_position(
            snake_head.get_occupied_positions(),
            Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)
        )
        update_game_speed()
        GameState.food_consumed.emit()

# Wall collision handler
func _on_wall_collision(wall_position: Vector2i) -> void:
    end_game()

# Self collision handler
func _on_self_collision(segment_position: Vector2i) -> void:
    end_game()
```

### 7.2 Data Flow Between Components

**Score Update Flow**:
1. Food is consumed
2. FoodController emits body_entered signal
3. GameManager receives signal and calls GameState.add_score()
4. GameState updates current_score and emits score_updated signal
5. UIController receives score_updated signal and updates display
6. If new high score, GameState saves to file

**Game State Transition Flow**:
1. User presses ESC or pause button
2. GameManager.pause_game() is called
3. GameManager calls GameState.set_game_state(GameStateEnum.PAUSED)
4. GameState updates state and emits state_changed signal
5. GameManager receives state_changed and pauses game timer
6. UIController receives state_changed and shows pause menu

**Movement Flow (Per Game Tick)**:
1. GameTimer emits timeout signal
2. GameManager processes pending input queue
3. GameManager calls SnakeController.move()
4. SnakeController calculates new head position
5. SnakeController updates position history
6. SnakeController updates body segment positions
7. SnakeController checks for self-collision
8. SnakeController emits movement_complete signal
9. GameManager checks for food collision
10. If food found, trigger consumption flow

### 7.3 Direct Reference Usage

For performance-critical operations, direct node references are used instead of signals:

```gdscript
# Direct reference for performance-critical movement
@onready var snake_head: CharacterBody2D = $snake_head
@onready var food: Area2D = $food

# Called every game tick - using direct reference
func _on_game_timer_timeout() -> void:
    var new_position = snake_head.move()
    
    # Direct position check for collision (faster than signal)
    if not is_position_valid(new_position):
        end_game()
        return
    
    # Direct food check
    if food.current_grid_position == new_position:
        consume_food()
```

---

## 8. File and Folder Structure

### 8.1 Project Directory Layout

```
snake-game/
├── assets/
│   ├── sprites/
│   │   ├── snake_head.png
│   │   ├── snake_body.png
│   │   ├── food.png
│   │   └── ui_icons.png
│   ├── audio/
│   │   ├── sfx/
│   │   │   ├── eat.wav
│   │   │   ├── collision.wav
│   │   │   ├── ui_click.wav
│   │   │   └── game_over.wav
│   │   └── music/
│   │       └── background_theme.wav
│   └── fonts/
│       └── default_font.ttf
├── autoloads/
│   └── game_state.gd
├── scenes/
│   ├── main.tscn
│   ├── snake_head.tscn
│   ├── snake_body.tscn
│   ├── food.tscn
│   ├── ui/
│   │   ├── ui.tscn
│   │   ├── main_menu.tscn
│   │   ├── hud.tscn
│   │   ├── pause_menu.tscn
│   │   └── game_over.tscn
│   └── effects/
│       ├── particle_consume.tscn
│       └── particle_death.tscn
├── scripts/
│   ├── main/
│   │   ├── game_manager.gd
│   │   ├── game_grid.gd
│   │   └── game_constants.gd
│   ├── snake/
│   │   ├── snake_controller.gd
│   │   └── snake_body.gd
│   ├── food/
│   │   └── food_controller.gd
│   ├── ui/
│   │   ├── ui_controller.gd
│   │   ├── main_menu_controller.gd
│   │   ├── hud_controller.gd
│   │   ├── pause_menu_controller.gd
│   │   └── game_over_controller.gd
│   └── utils/
│       ├── grid_utils.gd
│       ├── math_utils.gd
│       └── file_utils.gd
├── tests/
│   ├── unit/
│   │   ├── test_grid_utils.gd
│   │   ├── test_snake_movement.gd
│   │   └── test_game_state.gd
│   ├── integration/
│   │   ├── test_game_flow.gd
│   │   └── test_score_persistence.gd
│   └── performance/
│       └── test_movement_performance.gd
├── docs/
│   ├── specs/
│   │   └── PRODUCT_SPEC_SNAKE_GAME.md
│   ├── architecture/
│   │   ├── ARCHITECT_PLAN.md
│   │   └── diagrams/
│   │       ├── scene_tree.mmd
│   │       └── data_flow.mmd
│   ├── decisions/
│   │   └── ADR-001-movement-system.md
│   └── reports/
├── export/
│   └── presets/
│       └── windows_export.preset
├── CREDITS.txt
├── LICENSE
├── README.md
└── project.godot
```

### 8.2 Resource Naming Conventions

All resources follow consistent naming conventions to improve discoverability and prevent naming conflicts:

- **Scenes**: `snake_case.tscn` (e.g., `snake_head.tscn`, `main_menu.tscn`)
- **Scripts**: `snake_case.gd` matching scene name (e.g., `snake_head.gd`, `main_menu.gd`)
- **Sprites**: `snake_case.png` with descriptive prefixes (e.g., `snake_head.png`, `food_apple.png`)
- **Audio**: `category_description_format.wav` (e.g., `sfx_eat.wav`, `music_main.wav)
- **Colors/Themes**: `color_primary.tres`, `theme_main.tres`
- **Animations**: `animation_name.tres` (stored in `assets/animations/`)

### 8.3 Script Organization Guidelines

Each script file follows a consistent structure:

```gdscript
# File: scripts/category/script_name.gd
# Description: [Brief description of script purpose]

extends [Parent Node Type]

class_name ClassName

# ═══════════════════════════════════════════════════════════════
# SECTION: Signals
# ═══════════════════════════════════════════════════════════════

signal example_signal(value: int)

# ═══════════════════════════════════════════════════════════════
# SECTION: Constants
# ═══════════════════════════════════════════════════════════════

const CONSTANT_NAME: int = 10

# ═══════════════════════════════════════════════════════════════
# SECTION: Enums
# ═══════════════════════════════════════════════════════════════

enum EnumName { VALUE_ONE, VALUE_TWO }

# ═══════════════════════════════════════════════════════════════
# SECTION: Exported Variables
# ═══════════════════════════════════════════════════════════════

@export var export_var: int = 5

# ═══════════════════════════════════════════════════════════════
# SECTION: Public Variables
# ═══════════════════════════════════════════════════════════════

var public_var: String = ""

# ═══════════════════════════════════════════════════════════════
# SECTION: Private Variables
# ═══════════════════════════════════════════════════════════════

var _private_var: float = 0.0

# ═══════════════════════════════════════════════════════════════
# SECTION: Onready Variables
# ═══════════════════════════════════════════════════════════════

@onready var onready_node: Node2D = $path/to/node

# ═══════════════════════════════════════════════════════════════
# SECTION: Lifecycle Methods
# ═══════════════════════════════════════════════════════════════

func _ready() -> void:
    pass

func _exit_tree() -> void:
    pass

# ═══════════════════════════════════════════════════════════════
# SECTION: Public Methods
# ═══════════════════════════════════════════════════════════════

func public_method(param: int) -> void:
    pass

# ═══════════════════════════════════════════════════════════════
# SECTION: Private Methods
# ═══════════════════════════════════════════════════════════════

func _private_method() -> void:
    pass

# ═══════════════════════════════════════════════════════════════
# SECTION: Signal Handlers
# ═══════════════════════════════════════════════════════════════

func _on_node_signal() -> void:
    pass
```

---

## 9. Key Design Decisions

### 9.1 Movement System Decision

**Decision**: Timer-based grid movement with input queuing

**Rationale**: Timer-based movement provides consistent game speed regardless of frame rate, making gameplay predictable and fair. The input queue ensures rapid key presses are processed in order without being lost, while preventing 180-degree turns that would cause instant game over.

**Implementation Details**:
- GameTimer fires at intervals calculated from base_speed (5 tiles/sec initially)
- Direction changes are queued and processed one per game tick
- Movement is always exactly one grid cell (32 pixels)
- Position is stored as Vector2i for grid coordinates, converted to Vector2 for rendering

**Alternative Considered**: Delta-based movement with smooth interpolation
- **Rejected**: More complex to implement, harder to ensure consistent gameplay, potential for frame-rate dependent behavior

### 9.2 Collision Detection Decision

**Decision**: Area2D for food detection, coordinate-based for walls/self

**Rationale**: Area2D provides clean signal-based food detection that integrates well with Godot's physics system while remaining lightweight. Coordinate-based collision for walls and self-collision is more efficient than physics-based collision since it uses simple integer comparisons instead of physics engine overhead.

**Implementation Details**:
- Food uses Area2D with body_entered signal
- Wall collision checks new position against grid bounds
- Self-collision checks new position against body segment positions array
- All collision checks happen at game tick, not every frame

**Alternative Considered**: All collision via Area2D/CollisionShape2D
- **Rejected**: More physics overhead, potential for missed collisions during fast movement, harder to implement self-collision without special layer configurations

### 9.3 Scene Organization Decision

**Decision**: Snake head as CharacterBody2D, body segments as instanced Node2D scenes

**Rationale**: CharacterBody2D provides the movement and collision APIs needed for the head while remaining optimized for single-body physics. Body segments don't need physics behavior - they simply follow a position history - so Node2D is sufficient and more lightweight.

**Implementation Details**:
- Snake head: CharacterBody2D with move_and_slide() capability
- Body segments: Node2D scenes instantiated as children of snake_head
- Body segment positions update based on head's position history
- Segments are added/removed dynamically as snake grows/shrinks

**Alternative Considered**: All segments as Area2D or CharacterBody2D
- **Rejected**: Unnecessary physics overhead for segments that don't need collision response

### 9.4 State Management Decision

**Decision**: GameState autoload singleton with event bus pattern

**Rationale**: Autoload provides global accessibility without passing references everywhere. Event bus pattern enables loose coupling between components - UI doesn't need direct reference to game logic, it just listens for score updates.

**Implementation Details**:
- GameState autoloaded at project startup
- All game components can access via global `GameState` variable
- State changes broadcast via signals
- Components connect to signals they care about

**Alternative Considered**: Central StateManager node passed to all components
- **Rejected**: Requires manual reference passing, more error-prone, harder to add new components

### 9.5 UI Architecture Decision

**Decision**: Separate scenes for each UI panel with shared UIController

**Rationale**: Separate scenes enable modular UI development and testing. Each panel can be developed and tested independently. Shared controller handles transitions and common functionality.

**Implementation Details**:
- Each UI panel (menu, hud, pause, game_over) is a separate scene
- All panels are children of ui.tscn CanvasLayer
- UIController manages visibility transitions
- Panels communicate via GameState signals, not direct references

**Alternative Considered**: Single monolithic UI scene
- **Rejected**: Harder to maintain, difficult to test components in isolation, complex visibility management

---

## 10. Data Structures

### 10.1 Snake Body Representation

The snake body is represented using a hybrid structure that optimizes for both movement and collision detection:

```gdscript
# In SnakeController class
class_name SnakeController extends CharacterBody2D

# Array of body segment nodes (index 0 = first segment behind head)
var body_segments: Array[Node2D] = []

# Position history for trailing segments
# Index 0 = current head position, Index 1 = previous head position, etc.
var position_history: Array[Vector2i] = []

# Maximum history length (head + all body segments)
func get_max_history_length() -> int:
    return body_segments.size() + 1

# Get all occupied grid positions for collision checking
func get_occupied_positions() -> Array[Vector2i]:
    var positions: Array[Vector2i] = []
    
    # Add head position
    positions.append(get_current_grid_position())
    
    # Add body segment positions
    for segment in body_segments:
        positions.append(GridUtils.world_to_grid(segment.global_position, GRID_SIZE))
    
    return positions
```

### 10.2 Direction Queue

The direction queue uses a fixed-size array for predictable memory usage and performance:

```gdscript
# Direction queue with size limit
var direction_queue: Array[Direction] = []
const MAX_QUEUE_SIZE: int = 2  # Maximum pending direction changes

# Direction enum
enum Direction { UP, DOWN, LEFT, RIGHT }

# Process queue for current tick
func process_direction_queue() -> void:
    while not direction_queue.is_empty():
        var next_dir = direction_queue.pop_front()
        if is_valid_direction(next_dir):
            current_direction = next_dir
            break  # Only one direction change per tick
```

### 10.3 Grid Representation

Grid positions use Vector2i for integer-based coordinates:

```gdscript
# Grid bounds configuration
const GRID_SIZE: int = 32  # pixels per cell
const GRID_WIDTH: int = 20  # cells
const GRID_HEIGHT: int = 20  # cells

# Grid bounds as Rect2i for collision checking
var grid_bounds: Rect2i = Rect2i(0, 0, GRID_WIDTH, GRID_HEIGHT)

# Convert between world and grid coordinates
func world_to_grid(world_pos: Vector2) -> Vector2i:
    return Vector2i(
        int(world_pos.x / GRID_SIZE),
        int(world_pos.y / GRID_SIZE)
    )

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(
        grid_pos.x * GRID_SIZE,
        grid_pos.y * GRID_SIZE
    )
```

---

## 11. Testing Architecture

### 11.1 Unit Testing Strategy

The architecture is designed with testability in mind, enabling comprehensive unit testing of individual components:

**Testable Components**:
- GridUtils: Pure functions, fully testable
- SnakeController movement logic: Isolated from scene tree
- GameState: Singleton state management, testable with mocks
- Food spawning: Deterministic with seeded random

**Unit Test Structure**:
```gdscript
# tests/unit/test_grid_utils.gd
extends GutTest

func test_world_to_grid_conversion():
    var world_pos = Vector2(64, 96)
    var grid_pos = GridUtils.world_to_grid(world_pos, 32)
    assert_eq(grid_pos, Vector2i(2, 3))

func test_grid_to_world_conversion():
    var grid_pos = Vector2i(2, 3)
    var world_pos = GridUtils.grid_to_world(grid_pos, 32)
    assert_eq(world_pos, Vector2(64, 96))
```

### 11.2 Integration Testing Strategy

Integration tests verify component interactions:

```gdscript
# tests/integration/test_game_flow.gd
extends GutTest

func test_game_state_transitions():
    # Test complete game flow
    GameState.set_game_state(GameStateEnum.PLAYING)
    assert_eq(GameState.current_state, GameStateEnum.PLAYING)
    
    GameState.set_game_state(GameStateEnum.PAUSED)
    assert_eq(GameState.current_state, GameStateEnum.PAUSED)
    
    GameState.set_game_state(GameStateEnum.PLAYING)
    assert_eq(GameState.current_state, GameStateEnum.PLAYING)
```

### 11.3 Performance Testing

Performance tests verify the architecture meets NFRs:

```gdscript
# tests/performance/test_movement_performance.gd
extends GutTest

func test_movement_timing():
    var frame_times: Array[float] = []
    
    for i in range(1000):
        var frame_start = Time.get_ticks_usec()
        # Simulate game tick processing
        snake_head.move()
        var frame_end = Time.get_ticks_usec()
        frame_times.append((frame_end - frame_start) / 1000.0)
    
    var average_frame_time = average(frame_times)
    assert_lt(average_frame_time, 1.0)  # Less than 1ms per tick
```

---

## 12. Implementation Roadmap

### Phase 1: Core Foundation (Estimated: 4-6 hours)

1. Create project structure and configure project.godot
2. Implement GameState autoload with state management
3. Set up Input Map configuration
4. Create grid utility functions

### Phase 2: Game Entities (Estimated: 6-8 hours)

1. Implement SnakeController with movement and body management
2. Create FoodController with spawning logic
3. Build snake_head.tscn and snake_body.tscn scenes
4. Build food.tscn scene

### Phase 3: Game Loop (Estimated: 4-6 hours)

1. Implement GameManager with timer-based tick system
2. Create main.tscn scene with game grid
3. Implement collision detection (walls, self, food)
4. Connect all components through signals

### Phase 4: UI System (Estimated: 4-6 hours)

1. Create all UI scenes (menu, hud, pause, game_over)
2. Implement UI controllers with button handling
3. Connect UI to GameState signals
4. Add keyboard navigation support

### Phase 5: Polish and Testing (Estimated: 4-6 hours)

1. Add score persistence with JSON file storage
2. Implement progressive difficulty scaling
3. Add visual feedback (animations, particles)
4. Comprehensive testing and bug fixes

---

## 13. Risk Mitigation

### 13.1 Performance Risks

**Risk**: Snake length causes performance degradation  
**Probability**: Medium | **Impact**: High  
**Mitigation**: Use fixed array for position history, limit position history to current segment count, profile with maximum snake length during testing

**Risk**: Input handling lag on slower systems  
**Probability**: Low | **Impact**: Medium  
**Mitigation**: Input processed in _process(), not dependent on timer; implement input buffering for consistent response

### 13.2 Maintainability Risks

**Risk**: Tight coupling between components  
**Probability**: Low | **Impact**: Medium  
**Mitigation**: Architecture enforces loose coupling via signals; code review to verify no direct dependencies except through GameState

### 13.3 Development Risks

**Risk**: Scope creep during implementation  
**Probability**: Medium | **Impact**: Medium  
**Mitigation**: Clear requirements in product spec; architecture document frozen after approval; changes require formal scope change process

---

## 14. Appendices

### Appendix A: Godot 4.5.1 Specific Best Practices

- Use `@export` instead of `export` keyword
- Use type hints on all variables and parameters
- Use `super()` for parent method calls in `_ready()` and `_init()`
- Use `await` for signal connections instead of direct connection in `_ready()` when appropriate
- Use `Callable` for signal connections when needed
- Prefer `FileAccess` over older `File` class
- Use `JSON.new()` for JSON parsing (creates new instance to avoid state issues)

### Appendix B: GDScript Style Guide

- Class names: PascalCase (e.g., `SnakeController`)
- Function/variable names: snake_case (e.g., `move_snake`)
- Constant names: SCREAMING_SNAKE_CASE (e.g., `GRID_SIZE`)
- Private members: underscore prefix (e.g., `_private_method`)
- Signal names: past tense (e.g., `food_consumed`)

### Appendix C: Scene Instantiation Patterns

```gdscript
# Preload scene for instantiation
const BODY_SEGMENT_SCENE = preload("res://scenes/snake_body.tscn")

# Instantiate and add as child
var new_segment = BODY_SEGMENT_SCENE.instantiate()
body_segments_container.add_child(new_segment)
body_segments.append(new_segment)

# Remove segment
var removed_segment = body_segments.pop_back()
removed_segment.queue_free()
```

---

## 15. Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| v1.0 | 2026-01-04 | @architect | Initial architecture design based on product specification |

---

**Architecture Plan Status**: Ready for Implementation

This architecture plan defines a complete, testable, and maintainable implementation for the Snake game. The design follows Godot 4.5.1 best practices and addresses all requirements from the product specification. Implementation can proceed immediately based on this plan.

**Approval Required**: Explicit approval from project stakeholders required before beginning implementation phase.

**Next Steps**: Upon approval, delegate implementation tasks to specialized agents according to the implementation roadmap in Section 12.

---

*Document Control: This architecture plan will be updated only through formal change requests. Minor clarifications may be added without full re-approval process, but architectural changes require re-review.*
