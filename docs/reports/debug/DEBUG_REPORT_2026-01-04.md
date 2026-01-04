# Debug Report: Snake Game

**Date**: 2026-01-04
**Project**: Snake Game Clone (Godot 4.5.1)
**Status**: SUCCESS

## 1. Summary
Thorough testing was conducted through manual gameplay simulation and automated test suites. Six bugs were identified, ranging from low to critical severity. All identified bugs have been fixed and verified. Gameplay balance was validated and refined with a speed cap to ensure long-term playability.

## 2. Identified and Fixed Bugs

### BUG-001: Unused signal `collided_with_food`
**Severity:** Low
**Status:** Fixed
**Description:** The signal was declared in `snake.gd` but never emitted or used, causing a GDScript warning.
**Root Cause:** Food collision logic was moved to `main.gd` during development, leaving the signal redundant.
**Fix Applied:** Removed the signal declaration from `scripts/snake.gd`.
**Files Modified:** `scripts/snake.gd`

### BUG-002: Overlapping Initial Snake Segments
**Severity:** Medium
**Status:** Fixed
**Description:** On game start/reset, all initial snake segments (head + 2 body) were spawned at the same grid coordinate (10, 10).
**Root Cause:** `reset()` logic appended the same position multiple times.
**Fix Applied:** Updated `reset()` to initialize the snake in a horizontal line starting at (10, 10) and extending left.
**Files Modified:** `scripts/snake.gd`

### BUG-003: Eager Self-Collision (Tail Hit)
**Severity:** Medium
**Status:** Fixed
**Description:** Moving the head into the tile currently occupied by the tail triggered a game over, despite the tail being scheduled to move out in the same tick.
**Root Cause:** Collision check included the last element of the `positions` array before it was popped.
**Fix Applied:** Updated the self-collision check to use `positions.slice(0, -1)`, effectively ignoring the tail's current position for the next move.
**Files Modified:** `scripts/snake.gd`

### BUG-004: UI Freeze on Pause
**Severity:** Critical
**Status:** Fixed
**Description:** Entering the paused state froze the entire scene tree, including the UI. Buttons were non-responsive, and the game could not be resumed.
**Root Cause:** The UI nodes were not set to process while the tree was paused.
**Fix Applied:** Set `process_mode` to `Always` for the `UI` root node in `scenes/ui.tscn`.
**Files Modified:** `scenes/ui.tscn`

### BUG-005: Input/Resume Failure during Pause
**Severity:** High
**Status:** Fixed
**Description:** The ESC key could pause the game but not resume it, as the `Main` node's `_process` function stopped running during pause.
**Root Cause:** `main.gd` inherited the tree's paused state.
**Fix Applied:** Set `process_mode = PROCESS_MODE_ALWAYS` in `main.gd` and ensured game logic (movement) still respects the playing state.
**Files Modified:** `scripts/main.gd`

### BUG-006: Lack of Speed Cap
**Severity:** Low
**Status:** Fixed
**Description:** The progressive difficulty system increased speed indefinitely, potentially leading to unplayable speeds or input processing issues at extremely high scores.
**Root Cause:** No upper bound was defined for the speed calculation.
**Fix Applied:** Added a cap of 20.0 tiles/sec in the `_update_speed()` function.
**Files Modified:** `scripts/main.gd`

## 3. Gameplay Balance Validation

| Parameter | Value | Assessment |
|-----------|-------|------------|
| Starting Speed | 5 tiles/sec | Optimal: Provides a relaxed start for new players. |
| Speed Increment | +0.5 tiles/sec | Fair: Progression feels noticeable but not jarring. |
| Score Milestone | 50 points | Good: Requires 5 food items per difficulty increase. |
| Speed Cap | 20 tiles/sec | Necessary: Prevents the game from becoming humanly impossible. |
| Scoring | 10 pts / food | Balanced: Simple and clear math for players. |

## 4. Verification Evidence
- **Automated Tests**: Ran all 20 tests in `test_runner.tscn`. Result: 100% PASS.
- **Manual Verification**:
  - Verified snake initialization: Segments now appear in a line.
  - Verified pause/resume: UI remains responsive, ESC toggles pause correctly.
  - Verified tail collision: Head can move into the vacated tail tile safely.
  - Verified speed cap: Speed increases correctly up to the milestone limit.

## 5. Conclusion
The game is now stable, balanced, and responsive. All critical path bugs have been resolved, and the user experience is significantly improved through the fix of the pause menu and segment initialization logic.
