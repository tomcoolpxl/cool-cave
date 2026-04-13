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

## Phase 3 — Player movement system with input handling
- [x] Create `util/math_utils.lua` with `clamp()` and `lerp()` functions
- [x] Create `constants.lua` with movement constants (`RISE_ACC`, `FALL_ACC`, etc.)
- [x] Create `systems/player.lua` with fixed-timestep update and input handler
- [x] Integrate player system into `scenes/game.lua`
- [x] Verify avatar responds to hold/release input (rises on hold, falls on release)
- [x] Verify velocity clamping works as intended
- [x] Verify fixed timestep is used in player update

## Phase 4 — Seeded cave generator producing slice data
- [x] Create `util/random.lua` with Xorshift32 algorithm for cross-platform determinism
- [x] Create `systems/cave_generator.lua` using the deterministic RNG
- [x] Implement drifting centerline and bounded step changes for cave generation
- [x] Verify `math.random` is NOT used in any generation logic
- [x] Verify generator can be reset with the same seed to produce identical output
- [x] Enforce `MIN_GAP` and `MAX_STEP` constraints on every slice

## Phase 5 — Cave feasibility validator (reachability simulation)
- [x] Create `systems/cave_validator.lua` with reachability simulation
- [x] Implement discrete state set tracking for (y, vy)
- [x] Apply `VALIDATION_MARGIN` for safety during simulation
- [x] Integrate validator into `systems/cave_generator.lua` with retry/fallback logic
- [x] Implement known-safe straight fallback chunk for generator
- [x] Verify validator correctly rejects impossible chunks and accepts safe ones
- [x] Verify no `math.random` usage in validator

## Phase 6 — Cave rendering, scrolling, and collision detection
- [x] Create `systems/collision.lua` for AABB collision detection
- [x] Implement slice display object pool in `scenes/game.lua` for performance
- [x] Implement horizontal scrolling of cave slices
- [x] Implement slice recycling (off-screen slices returned to pool)
- [x] Integrate collision detection in `onFrame` loop
- [x] Verify game transitions to `gameover` on collision with top or bottom walls
- [x] Verify smooth scrolling and chunk generation without visual gaps

Verified on: Monday, April 13, 2026
OS: win32
Result: Success. Cave scrolls smoothly, and collision detection is accurate.
