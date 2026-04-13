# DONE.md — Verified Work

## Phase 1 — Project scaffold, build pipeline, and verified HTML5 output
- [x] Create `main.lua` with minimal Composer entry point
- [x] Create `config.lua` with landscape orientation and letterBox scale
- [x] Create `build.settings` with Android package name and landscape lock
- [x] Create `scenes/menu.lua` stub (placeholder label only)
- [x] Create empty `scenes/`, `systems/`, `util/`, `assets/`, `test/` directories with `.gitkeep`
- [x] Verify project opens and runs in Solar2D simulator (no Lua errors)
- [x] Print `display.contentWidth`/`Height` in simulator to confirm 960x540
- [x] Produce HTML5 build via Solar2D HTML5 build target
- [x] Serve HTML5 output via local HTTP server and verify in Chrome (no JS console errors)
- [x] Verify HTML5 output in Firefox (no JS console errors)
- [x] Write `DEV_NOTES.md` documenting Solar2D version, build steps, and local server command
- [x] Scope creep check: grep new files for player/cave/score/trail (comments only — PASS)

## Phase 2 — Composer Scene Skeleton and Game Loop Stub
- [x] Create `scenes/menu.lua` with tap-to-start navigation
- [x] Create `scenes/game.lua` with `enterFrame` loop and `onCollisionSim` tap
- [x] Create `scenes/gameover.lua` with tap-to-restart navigation
- [x] Verify state transitions: Menu -> Game -> Gameover -> Menu
- [x] Verify `enterFrame` starts and stops correctly (no console logs after scene exit)
- [x] Verify objects are correctly inserted into `self.view` for Composer management
- [x] Verify HTML5 build navigation without console errors

Verified on: Monday, April 13, 2026
OS: win32
Solar2D Simulator: C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe
Target: HTML5
Result: Success. Full navigation cycle confirmed. `enterFrame` logging verified to stop on hide.
