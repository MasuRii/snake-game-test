# UI Design Notes: Snake Game

> **Agent**: @ui
> **Date**: 2026-01-04
> **Project**: Snake Game Clone (Godot 4.5.1)
> **Status**: APPROVED for Implementation

---

## 1. Design System

### 1.1 Visual Aesthetic
The UI aims for a **Retro/Classic Arcade** look.
- **Vibe**: 8-bit, clean, nostalgic, high contrast.
- **Shapes**: Sharp corners (0px radius), thick borders (2px-4px).
- **Feedback**: Immediate visual response on hover/press.

### 1.2 Color Palette
High contrast colors meeting WCAG AA standards.

| Semantic | Hex | RGB | Purpose |
|----------|-----|-----|---------|
| **Background** | `#0F0F0F` | 15, 15, 15 | Main game background, screen overlays |
| **Panel BG** | `#1A1A1A` | 26, 26, 26 | Dialog/Menu backgrounds |
| **Border** | `#FFFFFF` | 255, 255, 255 | Panel borders, focus indicators |
| **Primary** | `#4D9BE6` | 77, 155, 230 | Primary actions (Start, Play Again) |
| **Secondary** | `#555555` | 85, 85, 85 | Secondary actions, inactive states |
| **Text Main** | `#FFFFFF` | 255, 255, 255 | Headings, primary labels |
| **Text Accent** | `#87E911` | 135, 233, 17 | Scores, success messages (Retro Green) |
| **Danger** | `#E64D4D` | 230, 77, 77 | Quit, Destructive actions |

### 1.3 Typography
**Font Family**: `Dogica` (or similar monospace pixel font).
**Fallback**: `Courier New`, `Monospace`.

| Style | Size | Line Height | Usage |
|-------|------|-------------|-------|
| **Display** | 64px | 1.2 | Main Title |
| **Heading 1** | 32px | 1.4 | Menu Headers, Game Over |
| **Heading 2** | 24px | 1.4 | Section Titles |
| **Body** | 20px | 1.5 | General text, Buttons |
| **Small** | 16px | 1.5 | Footers, Credits |

### 1.4 Components

#### Buttons
- **Shape**: Rectangular, 2px solid border.
- **Min Height**: 50px (mouse), 44px minimum for touch targets.
- **States**:
    - *Normal*: BG `#1A1A1A`, Text `#FFFFFF`, Border `#555555`
    - *Hover/Focus*: BG `#333333`, Text `#FFFFFF`, Border `#FFFFFF` (Scale 1.05x)
    - *Pressed*: BG `#000000`, Text `#AAAAAA`, Border `#FFFFFF` (Scale 0.95x)
    - *Disabled*: BG `#111111`, Text `#555555`, Border `#333333`

#### Panels
- **Style**: Solid Fill `#1A1A1A`, Border 4px `#FFFFFF`.
- **Padding**: 40px internal padding.

---

## 2. Screen Specifications

### 2.1 Main Menu
**Scene**: `main_menu.tscn`

#### Node Hierarchy
```
Control (Root) - Layout: Full Rect
├── TextureRect (Background) - Texture: Tiled grid or dark fill
├── CenterContainer (MainLayout) - Layout: Center
│   └── PanelContainer (MenuPanel) - ThemeType: "MenuPanel"
│       └── VBoxContainer (Content) - Separation: 32
│           ├── Label (Title) - Text: "SNAKE", Size: 64px, Align: Center
│           ├── VBoxContainer (Buttons) - Separation: 16
│           │   ├── Button (StartBtn) - Text: "START GAME"
│           │   ├── Button (SettingsBtn) - Text: "SETTINGS"
│           │   ├── Button (CreditsBtn) - Text: "CREDITS"
│           │   └── Button (QuitBtn) - Text: "QUIT"
│           └── VBoxContainer (HighScore) - Separation: 8
│               ├── Label (HSTitle) - Text: "HIGH SCORE", Color: Secondary
│               └── Label (HSValue) - Text: "000000", Color: Accent
```

#### Interaction Design
- **Start Game**: Transitions to Gameplay Scene immediately.
- **Buttons**: Navigate via Arrow Keys/TAB. Focus highlighted with white border.
- **Animation**: Title gently bobs up and down (Sin wave offset).

---

### 2.2 In-Game HUD
**Scene**: `hud.tscn`

#### Node Hierarchy
```
Control (Root) - Layout: Full Rect, MouseFilter: Ignore
├── MarginContainer (TopBar) - Margin: 20px all sides
│   └── HBoxContainer (Header)
│       ├── VBoxContainer (ScoreBox)
│       │   ├── Label (ScoreLabel) - Text: "SCORE", Size: 16px
│       │   └── Label (ScoreValue) - Text: "0", Size: 32px, Color: Accent
│       ├── Control (Spacer) - HSizeFlag: Expand
│       └── VBoxContainer (HighScoreBox)
│           ├── Label (HSLabel) - Text: "BEST", Size: 16px
│           └── Label (HSValue) - Text: "0", Size: 32px
└── Label (PauseHint) - Anchor: Bottom Left, Text: "ESC to Pause", Alpha: 0.5
```

#### Responsiveness
- **TopBar**: Stretches across top of screen.
- **Text**: Stays legible against game background (Game BG is dark, Text is white).

---

### 2.3 Pause Menu
**Scene**: `pause_menu.tscn`

#### Node Hierarchy
```
Control (Root) - Layout: Full Rect
├── ColorRect (Overlay) - Color: #000000, Alpha: 0.75
├── CenterContainer (CenterLayout)
│   └── PanelContainer (PausePanel)
│       └── VBoxContainer (Content) - Separation: 24
│           ├── Label (Title) - Text: "PAUSED", Size: 48px
│           ├── Button (ResumeBtn) - Text: "RESUME"
│           ├── Button (RestartBtn) - Text: "RESTART"
│           └── Button (MenuBtn) - Text: "MAIN MENU"
```

#### Behavior
- **Visibility**: Toggle on `ESC`.
- **Game State**: Game logic freezes.
- **Focus**: Automatically grabs focus on "RESUME" button.

---

### 2.4 Game Over Screen
**Scene**: `game_over.tscn`

#### Node Hierarchy
```
Control (Root) - Layout: Full Rect
├── ColorRect (Overlay) - Color: #0F0000 (Dark Red tint), Alpha: 0.85
├── CenterContainer (CenterLayout)
│   └── PanelContainer (GameOverPanel)
│       └── VBoxContainer (Content) - Separation: 32
│           ├── Label (Title) - Text: "GAME OVER", Color: Danger, Size: 64px
│           ├── VBoxContainer (ScoreSummary)
│           │   ├── Label (FinalScoreLabel) - Text: "Final Score"
│           │   ├── Label (FinalScoreValue) - Text: "1250", Size: 48px, Color: White
│           │   └── Label (NewHighScoreAlert) - Text: "NEW HIGH SCORE!", Color: Accent, Visible: False
│           └── HBoxContainer (Actions) - Separation: 20
│               ├── Button (PlayAgainBtn) - Text: "PLAY AGAIN", Theme: Primary
│               └── Button (MenuBtn) - Text: "MENU"
```

---

## 3. Accessibility & Usability

### 3.1 Keyboard Navigation
- **Focus Indication**: All interactive elements (buttons) must have a `StyleBoxFlat` with a 2px white border when in `focus` state.
- **Shortcuts**:
    - `ENTER` / `SPACE`: Activate focused button.
    - `ESC`: Trigger Pause / Back.
    - `ARROWS`: Navigation between buttons.
- **Tab Order**: Logical flow (Top to Bottom).

### 3.2 Visual Accessibility
- **Contrast**: All text uses White (#FFFFFF) or Accent Green (#87E911) on Dark Grey/Black backgrounds. Ratios exceed 7:1 (AAA).
- **Text Size**: Smallest font is 16px. Main UI text is 20px-24px.
- **Motion**: No flashing lights. Title animation is slow (0.5Hz).

### 3.3 Responsive Layouts
- **Anchors**: Use Godot's anchor system.
    - Menus: `CenterContainer` ensures centering on any aspect ratio.
    - HUD: `MarginContainer` ensures padding from screen edges regardless of resolution.
- **Scaling**: UI `Scale Mode` in Project Settings should be set to `CanvasItems` (keep pixel art crisp) or `Viewport` with `Keep Aspect`.

---

## 4. Implementation Details for Godot

### Theme Resource
Create a global `main_theme.tres` to enforce consistency.

```gdscript
# Resource Properties
Default Font: Dogica.ttf
Default Font Size: 20px

# StyleBoxFlat: PanelBackground
BG Color: #1A1A1A
Border Width: 4px
Border Color: #FFFFFF
Corner Radius: 0

# StyleBoxFlat: ButtonNormal
BG Color: #1A1A1A
Border Width: 2px
Border Color: #555555

# StyleBoxFlat: ButtonHover
BG Color: #333333
Border Width: 2px
Border Color: #FFFFFF
```

### Animation logic
Use `Tween` for UI transitions.
- **Fade In**: `modulate:a` from 0.0 to 1.0 over 0.2s.
- **Button Hover**: `scale` from 1.0 to 1.05 over 0.1s.

## 5. Verification Plan
1. **Run Scene**: Test `main_menu.tscn` independently.
2. **Keyboard Test**: Can navigate all buttons without mouse?
3. **Resize Test**: Resize window to 1024x768 and 1920x1080. Does HUD stay at edges? Does Menu stay centered?
4. **Contrast Check**: Verify text readability.
