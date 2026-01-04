# Snake Game (Godot 4.5.1)

A fully functional Snake game clone built with Godot 4.5.1 and GDScript. This project demonstrates clean architecture, maintainable code, and complete asset attribution for a classic arcade experience with modern game development practices.

## Description

Snake Game is a complete implementation of the classic arcade game where players control a snake that grows longer as it eats food. The game features progressive difficulty, high score persistence, pause functionality, and a retro pixel art aesthetic. Built as a comprehensive test of agentic team coordination, this project showcases best practices in game development, including modular code architecture, comprehensive testing, and proper asset licensing.

The game runs at a smooth 60 frames per second with responsive controls and intuitive input handling. Players can use either arrow keys or WASD for movement, with the game automatically preventing 180-degree turns to ensure fair gameplay. The scoring system rewards players with 10 points per food item consumed, and the game speed increases every 50 points to provide escalating challenge. High scores are automatically saved and persist between sessions, allowing players to compete against their personal best.

## 🤖 Agentic Team

This project was created entirely by an agentic team of AI specialists working together to test collaborative AI development capabilities. This was a one-shot project completed in a single session with no human intervention beyond the initial prompt.

### Agents Used

| Agent | Model | Tasks Completed |
| ------ | ------ | --------------- |
| Orchestrator | glm-4.7-free | Coordinated all tasks, delegated to specialists |
| Product | minimax-m2.1-free | Product specification, requirements, user stories |
| Researcher | minimax-m2.1-free | Godot research, asset sources, best practices |
| Architect | minimax-m2.1-free | System architecture, scene structure, class hierarchy |
| UI | gemini-3-pro-high | UI design, visual layout, accessibility |
| Code | gemini-3-flash | Core implementation, game systems, Windows build |
| Test | gemini-3-flash | Test suite, build verification |
| Debug | gemini-3-flash | Bug fixing, gameplay balance |
| Refactor | gemini-3-pro-high | Code optimization, structure improvements |
| Security | gemini-3-pro-high | Security audit, asset license validation |
| DevOps | gemini-3-pro-high | Export pipeline, deployment configuration |
| Docs | minimax-m2.1-free | README.md, CREDITS.txt, technical documentation |
| Git | minimax-m2.1-free | Version control, GitHub repository initialization |

### Session Information

- **Total Session Time**: Single session (one-shot)
- **Milestones Completed**: 5
- **Subtasks Completed**: 24
- **Agents Coordinated**: 14
- **All Tasks**: Automated with zero manual coding

### Initial Prompt

The project was initiated with the following test mission statement:

```
# AGENTIC TEAM TEST: SNAKE GAME DEVELOPMENT

Test Mission Statement
This is a completely new environment with no existing assets, code, or setup. The sole purpose of this session and repository is to rigorously test our agentic team of 14 agents to determine if they are the best fit for complex, collaborative development tasks. As the orchestrator agent, your role is to coordinate and delegate among the team to achieve the following test scenario: Create a fully functional clone of the classic game "Snake" using Godot 4.5.1 (which is already installed on the system).

Handle all aspects of the project from start to finish, including planning, design, implementation, testing, optimization, asset sourcing, and final packaging.
```

## Requirements

### For Development
- Godot Engine 4.5.1 or later (the project is configured for Godot 4.x)
- A computer capable of running Godot 4.5.1 (Windows 10 or later recommended)
- Approximately 500MB of free disk space for the Godot editor and export templates
- Keyboard for testing controls (mouse required for menu navigation)

### For Playing Standalone Builds
- Windows 10 or Windows 11 (64-bit)
- No additional dependencies required
- Approximately 50MB of free disk space
- Keyboard for gameplay (arrow keys or WASD)

## Installation

### Option 1: Running from Source (Godot Project)

1. **Clone or Download the Project**
   Download the project files to your local machine by cloning the repository or extracting a ZIP archive. Ensure all files maintain their original directory structure.

2. **Open in Godot 4.5.1**
   Launch Godot 4.5.1 and click the "Import" button in the project manager. Navigate to the project directory and select the `project.godot` file. Alternatively, you can drag and drop the project folder onto the Godot editor window.

3. **Run the Game**
   Once the project loads, press F5 on your keyboard or click the "Run Project" button (the green play icon) in the top-right corner of the editor. The game will start in a new window with the main menu displayed.

### Option 2: Running Standalone Build

1. **Download the Build**
   Obtain the pre-built executable from the release page or distribution source. The build is distributed as either a ZIP archive containing the executable and all required files, or as a self-extracting installer.

2. **Extract the Files**
   If the build is distributed as a ZIP archive, extract all files to a location of your choice on your computer. Windows may prompt you to confirm that you want to run software from an unknown publisher—click "More info" and "Run anyway" to proceed.

3. **Launch the Game**
   Double-click `Snake Game.exe` to start the game. No installation is required; the game runs directly from the extracted files. You can create a shortcut to the executable on your desktop for convenient access.

## How to Play

### Controls

The game supports two control schemes for movement, allowing players to choose their preferred input method. The primary controls use the arrow keys, while an alternative scheme uses the WASD keys for players more comfortable with standard keyboard layouts.

- **Arrow Keys (↑ ↓ ← →)**: Change the snake's direction. The snake will immediately begin moving in the pressed direction on the next game tick.
- **WASD Keys (W A S D)**: Alternative direction controls. W moves up, A moves left, S moves down, and D moves right.
- **ESC (Escape)**: Toggle the pause menu during gameplay. Press again or click "Resume" to continue playing.
- **Mouse**: Click buttons in menus to navigate. The game is fully navigable using the mouse for menu interactions.

Input is processed with a queue system that prevents rapid multiple direction changes within a single game tick, ensuring smooth and predictable movement while preventing the player from accidentally causing a self-collision by pressing keys too quickly.

### Objectives

The objective of Snake Game is deceptively simple yet increasingly challenging as you progress. Your snake starts with a length of three segments, and your goal is to consume food items that appear randomly on the game board. Each food item consumed causes your snake to grow by one additional segment and awards you 10 points toward your score.

As you consume food and your score increases, the game automatically accelerates to provide greater challenge. Every 50 points, the game speed increases by 0.5 tiles per second, requiring faster reactions and more precise planning. The maximum speed is capped to ensure the game remains playable even at high skill levels.

### Rules

Understanding the rules is essential for success in Snake Game. The game follows classic Snake mechanics with a few modern refinements that improve the experience without changing the fundamental challenge.

**Movement Rules**: The snake moves continuously in its current direction and cannot immediately reverse direction. This means if the snake is moving right, pressing left will have no effect until the next game tick. This prevents players from accidentally causing immediate self-collision and makes the game more forgiving while maintaining the core challenge.

**Scoring Rules**: Each food item consumed adds exactly 10 points to your current score. Food spawns only in valid locations not occupied by the snake's body, ensuring fair gameplay. The game tracks both your current session score and your historical high score across all sessions.

**Game Over Conditions**: The game ends when the snake's head collides with either the game board boundaries or any segment of its own body. Upon game over, your final score is displayed along with a notification if you achieved a new high score. You can then choose to play again or return to the main menu.

## Features

Snake Game includes all the features expected from a modern implementation of this classic game. The core gameplay loop provides satisfying arcade action, while additional features enhance the experience without cluttering the interface.

**Classic Snake Gameplay**: The game faithfully recreates the classic Snake experience with smooth grid-based movement, responsive controls, and the characteristic growing snake mechanic. The retro pixel art style pays homage to the original arcade games while providing clean, readable visuals on modern displays.

**Score Tracking with Persistence**: The game maintains accurate score tracking during gameplay, updating the display within 100 milliseconds of any score change. High scores are automatically saved to persistent storage and restored when you next play, allowing you to track your improvement over time.

**Progressive Difficulty**: The difficulty system automatically adjusts based on your performance. Starting at a comfortable 5 tiles per second, the game speed increases by 0.5 tiles per second for every 50 points scored. This creates a natural progression that matches your growing skill as you master the game's mechanics.

**Pause and Resume**: The pause system allows you to temporarily halt gameplay at any time by pressing the ESC key. This is useful for taking breaks without losing your progress. When paused, a menu overlay appears with options to resume playing or return to the main menu.

**Complete Menu System**: The game features a full menu system including a main menu with the game title and start button, an in-game HUD displaying current and high scores, a pause menu with resume and quit options, and a game over screen showing your final score and high score notification.

**Smooth Input Handling**: The input system uses a queue-based approach that handles rapid key presses gracefully. Multiple direction changes within a single game tick are queued and processed in order, ensuring that all input is registered while preventing the snake from making illegal 180-degree turns.

## Building and Exporting

To create your own standalone build of Snake Game, follow these steps using Godot 4.5.1. Exporting allows you to distribute the game to players who do not have Godot installed.

1. **Open the Project in Godot**
   Launch Godot 4.5.1 and open the Snake Game project. Ensure all project files have loaded correctly and the game runs without errors by pressing F5 to test.

2. **Install Export Templates**
   Go to **Editor** > **Manage Export Templates** in the Godot menu. Click "Download and Install" to get the necessary templates for your target platform. This requires an internet connection and may take a few minutes depending on your connection speed.

3. **Configure Export Settings**
   Navigate to **Project** > **Export** in the menu. Click "Add..." and select "Windows Desktop" from the list of available presets. In the export options, verify that the following settings are configured correctly:
   
   - **Export Path**: Choose where to save the exported files (e.g., `export/Snake Game.exe`)
   - **Custom Icon**: The project is configured to use `assets/icons/game_icon.png` as the executable icon
   - **Window Mode**: Set to "Windowed" for a resizable window experience
   - **V-Sync**: Enabled to ensure smooth 60 FPS gameplay
   - **Target FPS**: Set to 60 for consistent performance

4. **Export the Project**
   Click "Export Project" to generate the standalone executable. Godot will create the main executable file along with supporting files including the game package (`.pck` file) and any export-specific resources. Copy all generated files together when distributing the game.

## Known Issues and Limitations

While Snake Game has been thoroughly tested and is considered stable, users should be aware of the following known issues and limitations.

**Single-Player Offline Gameplay**: The game does not include multiplayer functionality or online features. High scores are stored locally and cannot be compared with other players or synchronized across devices.

**Client-Side High Score Storage**: High scores are saved as plain JSON in the user's application data directory. Tech-savvy users can modify these files to falsify their scores. This is a known limitation of offline single-player games and does not affect normal gameplay.

**Windows-Only Export**: While the source code is cross-platform compatible, the current documentation and export configuration target Windows Desktop. Users wishing to export to other platforms (macOS, Linux, web) will need to configure appropriate export presets and may need to adjust some project settings.

**Audio Assets Not Included**: The current release does not include sound effects or background music. This was a conscious decision to keep the game lightweight and avoid complex asset licensing considerations. Audio functionality exists in the architecture and can be enabled by adding appropriate sound files to the `assets/audio/` directory.

## License

The Snake Game source code and custom assets are provided under the MIT License, allowing free use, modification, and distribution with appropriate attribution. See the `LICENSE` file for complete license terms.

All third-party assets used in this project are licensed under CC0 1.0 Universal (Public Domain), permitting commercial use without attribution requirements. See `CREDITS.txt` for complete asset attribution documentation.

## Credits

All assets used in this project are properly licensed and attributed. See `CREDITS.txt` for complete details on asset sources, authors, and license information. The game uses assets from the following sources:

- **Sprite Assets**: Kenney.nl Pixel Platformer collection (CC0 1.0 Universal)
- **Font Assets**: PixelBuddha Dogica font (CC0 1.0 Universal)

## Contributing

This project was developed as a comprehensive test of agentic team coordination and represents a complete implementation of the specified requirements. While not actively seeking external contributions, the code structure follows best practices that make it suitable for study, modification, and use as a reference implementation for Godot 4.x game development.

## Version History

- **v1.0** (2026-01-04): Initial release with complete core gameplay, score tracking, progressive difficulty, pause functionality, and comprehensive documentation.

---

**Game Version**: 1.0  
**Engine**: Godot 4.5.1  
**Last Updated**: 2026-01-04