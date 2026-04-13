# CoolCave — Implementation Plan

---

## Overview

CoolCave is a one-input survival game built in Solar2D (Lua), targeting **HTML5 first** and **Android second**. The player controls a flat rectangular avatar that rises while input is held and falls when released, navigating a horizontally scrolling cave generated deterministically from a fixed seed. The cave is validated for feasibility before use. Score is time survived. Trail is rendered as a chain of small blocks.

This plan covers the full MVP as defined in `REQUIREMENTS.md`, from project scaffold through Android APK verification.

---

## Assumptions

| # | Assumption | Impact if wrong |
|---|---|---|
| A1 | Development machine has Solar2D simulator installed (2025.3722 or later) | All phases blocked until resolved |
| A2 | HTML5 builds are produced via Solar2D's built-in HTML5 build target (no separate tool) | Phase 1 build step changes |
| A3 | A local HTTP server is available for HTML5 testing. **Windows note:** use `python -m http.server 8000` (not `python3`) if Python was installed via the standard Windows installer. Alternatively `npx serve` or `npx http-server` work without Python. Document the working command in `DEV_NOTES.md` during Phase 1. | Phase 1 and Phase 10 test method changes |
| A4 | Android SDK is installed (confirmed). Debug keystore must be generated before Phase 12 (`keytool -genkey ...`). A physical Android device or AVD emulator must be available and reachable via `adb devices`. | Phase 12 blocked if device/emulator not available |
| A5 | Manual vertical kinematics (position + velocity + acceleration) are used — Box2D physics engine is **not** used | Phase 2 fundamentally changes if wrong |
| A6 | The seeded RNG is a **pure Lua Xorshift32 implementation** in `util/random.lua`, NOT `math.randomseed` + `math.random`, to guarantee identical output across platforms and Solar2D versions | Determinism guarantee breaks if wrong |
| A7 | Persistence uses a `loadsave.lua` helper that reads/writes JSON to `system.DocumentsDirectory` | Phase 7 implementation changes |
| A8 | MVP targets **landscape orientation only** (per REQUIREMENTS.md clarification: "start with landscape only for mvp") | Phase 1 config changes if wrong |
| A9 | The fixed seed value for all runs is defined in a constants table in `config.lua` or a dedicated `constants.lua` | Minor refactor if moved elsewhere |
| A10 | Trail is rendered as a chain of small square display objects pooled in a fixed-size circular buffer | Performance profile changes if wrong |
| A11 | Scene management uses Solar2D's built-in **Composer** library | Phase 2 architecture changes |
| A12 | Collision detection is manual AABB checks against active cave slice data — no physics bodies | Phase 5 implementation changes |
| A13 | Audio files are short OGG/MP3 clips; background ambient is optional and deferred if HTML5 audio issues arise | Phase 9 scope may shrink |

---

## Delivery strategy

**Hybrid: vertical slice per subsystem, layered integration.**

Each phase delivers one working, testable subsystem in isolation. Integration phases then wire subsystems together into a playable game. This is the right choice because:

- Solar2D has no compile step for individual modules — each file can be tested in isolation via the simulator with a small harness.
- The cave generator and feasibility validator are algorithmically risky and must be proven correct before they are coupled to rendering.
- HTML5 and Android have platform-specific integration risks (audio, build pipeline, input) that must be isolated into their own phases so they do not contaminate core gameplay review.
- Review cadence assumes single-developer iteration with self-review, so phases must be small enough to review in one sitting (< ~300 lines of new code excluding boilerplate).

---

## Phase list

| ID | Title |
|---|---|
| Phase 1 | Project scaffold, build pipeline, and verified HTML5 output |
| Phase 2 | Scene skeleton with Composer and game loop stub |
| Phase 3 | Player movement system with input handling |
| Phase 4 | Seeded cave generator producing slice data |
| Phase 5 | Cave feasibility validator (reachability simulation) |
| Phase 6 | Cave rendering, scrolling, and collision detection |
| Phase 7 | Trail rendering (chain of small blocks) |
| Phase 8 | Score tracking and local persistence |
| Phase 9 | Full game flow integration (title, gameplay, game-over, restart) |
| Phase 10 | Audio integration with HTML5 compatibility |
| Phase 11 | HTML5 verification, polish, and browser sign-off |
| Phase 12 | Android build pipeline and device verification |
| Phase 13 | Stabilization and final review |

---

## Detailed phases

---

### Phase 1 — Project scaffold, build pipeline, and verified HTML5 output

#### Goal

A buildable, runnable Solar2D project exists, produces a working HTML5 output served from a local web server, and displays a placeholder screen. All required project files are present and correctly structured.

#### Scope

- Create the Solar2D project directory structure.
- Write `main.lua` as a minimal entry point (display a single text label).
- Write `config.lua` with landscape orientation, base content area, and scale mode.
- Write `build.settings` with landscape lock, Android package name, and minimum SDK version.
- Confirm the project runs in the Solar2D simulator.
- Produce an HTML5 build and verify it loads in a browser via local HTTP server.
- Document the local dev workflow (how to build HTML5, how to serve, how to open in browser).

Out of scope: any game logic, scenes, or systems.

#### Expected files to change

```
main.lua                  (new — entry point, require Composer, go to menu scene stub)
config.lua                (new — landscape, letterbox scale, base width/height)
build.settings            (new — orientation landscape, Android minSdkVersion, package name)
util/                     (new directory)
scenes/                   (new directory, empty)
systems/                  (new directory, empty)
assets/                   (new directory, placeholder)
DEV_NOTES.md              (new — documents build steps, local server command, browser test steps)
```

#### Dependencies

- Solar2D simulator installed (A1).
- No prior phases required.

#### Risks

**Low.** This is boilerplate. Main risk: incorrect `config.lua` base resolution causes rendering issues in later phases. Mitigate by matching base resolution to a common landscape target (e.g. 960×540) and testing letterbox scaling.

#### Tests and checks to run

- Open project in Solar2D simulator — must display placeholder label without errors in simulator console.
- Build HTML5 via Solar2D HTML5 build target.
- Serve build output: `python3 -m http.server 8000` (or equivalent) from the HTML5 output folder.
- Open `http://localhost:8000` in Chrome and Firefox — must display placeholder label without console errors.
- Verify landscape orientation is enforced in both simulator and browser.

#### Review check before moving work to `DONE.md`

- [ ] `config.lua` uses landscape orientation and a sensible base resolution.
- [ ] `build.settings` has the correct package name and orientation lock.
- [ ] HTML5 output loads without JS console errors.
- [ ] Simulator runs without Lua errors.
- [ ] `DEV_NOTES.md` documents the full local build-and-test workflow.
- [ ] No game logic was added (scope creep check).
- [ ] All TODO entries for this phase written back to `TODO.md`.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 1

- [ ] Create main.lua with minimal Composer entry point
- [ ] Create config.lua with landscape orientation and letterbox scale
- [ ] Create build.settings with Android package name and landscape lock
- [ ] Create empty scenes/, systems/, util/, assets/ directories with .gitkeep
- [ ] Verify project opens and runs in Solar2D simulator (no Lua errors)
- [ ] Produce HTML5 build via Solar2D HTML5 build target
- [ ] Serve HTML5 output via local HTTP server and verify in Chrome
- [ ] Verify HTML5 output in Firefox
- [ ] Write DEV_NOTES.md documenting build steps and local test workflow
```

#### Exit criteria for moving items to `DONE.md`

- `main.lua`, `config.lua`, `build.settings` all exist with correct content.
- Simulator shows placeholder label with zero Lua errors in console.
- HTML5 build was produced and loads at `localhost:8000` with zero JS console errors in Chrome.
- `DEV_NOTES.md` exists and contains the local server command and browser test steps.

---

### Phase 2 — Scene skeleton with Composer and game loop stub

#### Goal

The Composer scene graph is wired. Three scenes exist as stubs: `menu`, `game`, and `gameover`. The game loop runs at 60 FPS in the `game` scene. Navigation between scenes is functional via placeholder tap/click.

#### Scope

- Implement `scenes/menu.lua` as a stub showing "CoolCave" title and a tap-to-start prompt.
- Implement `scenes/game.lua` as a stub with a running `enterFrame` listener at 60 FPS and a placeholder rectangle.
- Implement `scenes/gameover.lua` as a stub showing "Game Over" and a tap-to-restart that returns to menu.
- Wire scene transitions in `main.lua`.
- Verify scene transitions are smooth in simulator and HTML5.

Out of scope: actual gameplay, scoring, or systems. These are stubs only.

#### Expected files to change

```
main.lua                  (updated — require Composer, navigate to scenes/menu)
scenes/menu.lua           (new — stub title screen with tap listener)
scenes/game.lua           (new — stub game scene with enterFrame loop at 60 FPS)
scenes/gameover.lua       (new — stub game-over screen with tap-to-restart)
```

#### Dependencies

- Phase 1 complete and passing exit criteria.

#### Risks

**Low.** Composer is a stable Solar2D API. Main risk: event listener leak if scenes are not cleaned up correctly. Mitigate by using `scene:destroy()` and removing all listeners in `scene:hide()` / `scene:destroy()` handlers.

#### Tests and checks to run

- Simulator: tap through menu → game → gameover → menu without Lua errors.
- HTML5: same navigation in browser.
- Verify Solar2D simulator console shows 60 FPS (or simulator-limited FPS) with no frame drops from the loop itself.
- Verify no event listener accumulation (add a print in enterFrame to confirm it fires once per frame and stops when scene exits).

#### Review check before moving work to `DONE.md`

- [ ] All three scene files exist and navigate correctly.
- [ ] No Lua errors in simulator or browser during navigation.
- [ ] `enterFrame` listener is correctly added and removed in game scene lifecycle.
- [ ] No actual gameplay code added (scope check).
- [ ] Phase 3 blockers identified and written to `TODO.md`.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 2

- [ ] Create scenes/menu.lua stub with title label and tap-to-start
- [ ] Create scenes/game.lua stub with enterFrame listener and placeholder rect
- [ ] Create scenes/gameover.lua stub with game-over label and tap-to-restart
- [ ] Wire scene navigation in main.lua
- [ ] Verify tap-through navigation works in simulator (no Lua errors)
- [ ] Verify tap-through navigation works in HTML5 browser build
- [ ] Confirm enterFrame listener is cleaned up on scene exit (add debug print)
```

#### Exit criteria for moving items to `DONE.md`

- All three scene stubs exist.
- Full navigation cycle (menu → game → gameover → menu) works in both simulator and browser with zero Lua/JS errors.
- `enterFrame` cleanup confirmed via console output.

---

### Phase 3 — Player movement system with input handling

#### Goal

`systems/player.lua` is a working, self-contained module. It simulates vertical kinematics with floaty feel, responds to hold/release input, and renders the avatar as a flat rectangle. It can be dropped into the game scene stub and tested in isolation.

#### Scope

- Implement `util/math_utils.lua` with clamp and lerp helpers.
- Implement `systems/player.lua`:
  - Avatar state: `y`, `vy`.
  - Update function: apply upward or downward acceleration per frame based on input state, clamp velocity.
  - Render: `display.newRect()` avatar, update position each frame.
  - Input: `touch` event (HTML5 mouse + Android touch) sets `isHeld` flag.
- Integrate into `scenes/game.lua` for visual testing.
- Tune constants: rise acceleration, fall acceleration, max upward speed, max downward speed.
- Constants live in `config.lua` or a new `constants.lua`.

Out of scope: collision with cave, trail, cave itself.

#### Expected files to change

```
systems/player.lua        (new — kinematics, input, rectangle render)
util/math_utils.lua       (new — clamp, lerp)
constants.lua             (new — RISE_ACC, FALL_ACC, MAX_VY_UP, MAX_VY_DOWN, AVATAR_W, AVATAR_H, PLAYER_X)
scenes/game.lua           (updated — instantiate player, call player:update() in enterFrame)
config.lua                (possibly updated — add display constants if not using constants.lua)
```

#### Dependencies

- Phase 2 complete.
- No cave system required — player tested against screen bounds only.

#### Risks

**Low-medium.** The kinematics model must be deterministic across platforms (same timestep). Risk: Solar2D's `event.time` delta may not be consistent across HTML5 and native. Mitigate by using a **fixed timestep** (1/60 s) in the update function rather than `delta = event.time - lastTime`. Document this choice explicitly in `player.lua`.

#### Tests and checks to run

- Simulator: avatar rises while mouse button held, falls on release, feels floaty (not instant direction change).
- Check velocity clamp works: hold for 3 seconds, verify avatar does not accelerate past max speed.
- HTML5: same behavior in browser with mouse input.
- No Lua errors during input in either environment.
- Manual feel test: avatar should feel controllable, not twitchy.

#### Review check before moving work to `DONE.md`

- [ ] `player.lua` does not import any cave or scene state — it is self-contained.
- [ ] Fixed timestep is used, not delta-time from events.
- [ ] All movement constants are in `constants.lua`, not hardcoded in `player.lua`.
- [ ] Avatar is distinguishable (color/contrast noted).
- [ ] Input works in both simulator (mouse) and HTML5 browser (mouse click/hold).
- [ ] Floaty feel verified manually.
- [ ] No scope creep (no trail, no collision, no cave).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 3

- [ ] Create util/math_utils.lua with clamp() and lerp() functions
- [ ] Create constants.lua with RISE_ACC, FALL_ACC, MAX_VY_UP, MAX_VY_DOWN, AVATAR_W, AVATAR_H, PLAYER_X
- [ ] Create systems/player.lua with y/vy state, fixed-timestep update, rise/fall acceleration
- [ ] Add velocity clamping to player update
- [ ] Implement touch/mouse input handler setting isHeld flag in player.lua
- [ ] Integrate player into scenes/game.lua enterFrame loop
- [ ] Test: avatar rises on hold, falls on release, in simulator
- [ ] Test: avatar behavior matches in HTML5 browser build
- [ ] Test: velocity clamp works (hold 3 seconds, check max speed not exceeded)
- [ ] Manual feel test: confirm floaty, non-twitchy movement
- [ ] Confirm fixed timestep is used (document in player.lua comment)
```

#### Exit criteria for moving items to `DONE.md`

- `systems/player.lua` exists with kinematics and input handler.
- `util/math_utils.lua` exists with clamp and lerp.
- `constants.lua` exists with all movement tuning values.
- Avatar behaves identically in simulator and HTML5 browser.
- All movement constants are externalized.
- Feel test passed by reviewer.

---

### Phase 4 — Seeded cave generator producing slice data

#### Goal

`systems/cave_generator.lua` produces deterministic, seeded cave geometry as a sequence of slice records. Given the same seed, it always produces the same output. Geometry obeys all bounded constraints from REQUIREMENTS.md. `util/random.lua` provides a pure Lua Xorshift32 RNG.

#### Scope

- Implement `util/random.lua`:
  - Xorshift32 algorithm (pure Lua, no `math.random`).
  - `rng.new(seed)` constructor.
  - `rng:next()` returning float in [0, 1).
  - `rng:nextInt(min, max)` returning integer in [min, max].
- Implement `systems/cave_generator.lua`:
  - `generator.new(seed, params)` constructor.
  - `generator:generateChunk(count)` returns an array of `count` slice records.
  - Each slice: `{ x, topY, bottomY }`.
  - Generation uses drifting centerline + bounded random step changes.
  - Enforces: min gap, max per-step wall change, bounded center drift.
  - Chunk size defined in `constants.lua`.
- Write a standalone test harness (optional Lua script or inline test in `main.lua` debug mode) that prints generated slice values to confirm determinism across two runs with the same seed.

Out of scope: feasibility validation (Phase 5), rendering (Phase 6).

#### Expected files to change

```
util/random.lua           (new — Xorshift32 RNG)
systems/cave_generator.lua (new — chunk-based slice generation)
constants.lua             (updated — CHUNK_SIZE, MIN_GAP, MAX_STEP, CENTER_DRIFT_MAX, SCROLL_SPEED)
test/cave_gen_test.lua    (new — optional debug harness, not shipped in release)
```

#### Dependencies

- Phase 1 complete (project structure exists).
- Phase 3 complete — `constants.lua` exists and movement constants are settled. The generator's gap and step limits must be tuned relative to the movement constants.

#### Risks

**Medium.** The determinism guarantee depends entirely on using the pure Lua RNG and not mixing in any `math.random` calls. Risk: accidental use of `math.random` somewhere in the generator breaks determinism silently. Mitigate by grepping for `math.random` in generator and RNG files before review.

Secondary risk: unbounded generation could produce non-traversable caves even before the validator exists. Mitigate by choosing conservative defaults (large min gap, small max step) during this phase.

#### Tests and checks to run

- Run generator with seed `12345`, print first 20 slices, run again with same seed — output must be byte-identical.
- Run generator with seed `99999`, print first 20 slices — output must differ from seed `12345`.
- Verify: every slice has `bottomY - topY >= MIN_GAP`.
- Verify: no two adjacent slices differ by more than `MAX_STEP` in topY or bottomY.
- Grep `systems/cave_generator.lua` and `util/random.lua` for `math.random` — must return zero matches.

#### Review check before moving work to `DONE.md`

- [ ] `util/random.lua` implements Xorshift32 with no dependency on `math.random`.
- [ ] Same seed produces identical output in two separate runs (tested and confirmed in output).
- [ ] All generation parameters are in `constants.lua`, not hardcoded.
- [ ] MIN_GAP and MAX_STEP are set to conservative values for this phase.
- [ ] No rendering or display code in generator (scope check).
- [ ] `grep math.random` passes (zero matches in generator and RNG files).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 4

- [ ] Create util/random.lua with Xorshift32 RNG (new, nextInt methods)
- [ ] Verify Xorshift32 produces known deterministic output for seed 12345
- [ ] Create systems/cave_generator.lua with generateChunk(count) returning slice array
- [ ] Implement drifting centerline generation with bounded step changes
- [ ] Enforce MIN_GAP on every slice in generator
- [ ] Add CHUNK_SIZE, MIN_GAP, MAX_STEP, CENTER_DRIFT_MAX to constants.lua
- [ ] Write debug harness: run generator twice with same seed, compare output (must match)
- [ ] Run debug harness with two different seeds, confirm outputs differ
- [ ] Grep cave_generator.lua and random.lua for math.random (must return 0 matches)
- [ ] Verify all slices in a sample chunk satisfy MIN_GAP and MAX_STEP bounds
```

#### Exit criteria for moving items to `DONE.md`

- `util/random.lua` and `systems/cave_generator.lua` both exist.
- Determinism test passes: identical output for same seed across two runs.
- All slices pass MIN_GAP and MAX_STEP checks in the debug harness.
- `math.random` grep returns zero matches.
- All constants externalized in `constants.lua`.

---

### Phase 5 — Cave feasibility validator (reachability simulation)

#### Goal

`systems/cave_validator.lua` implements the discrete reachability simulation described in REQUIREMENTS.md. It accepts a chunk of slices and a movement model, and returns whether the chunk is traversable. It uses the **same movement constants** as `player.lua`.

#### Scope

- Implement `systems/cave_validator.lua`:
  - `validator.check(slices, params)` returning `true` (feasible) or `false`.
  - Simulation: maintain a set of `(y, vy)` states at each slice.
  - For each slice, expand states by simulating one fixed timestep with input held and one with input released.
  - Discard states where the avatar (with safety margin shrink on hitbox) intersects the cave walls.
  - If the surviving state set is empty, return false.
  - Apply safety margin: shrink the usable gap by `VALIDATION_MARGIN` during simulation.
  - Include max retry count and fallback pattern in `cave_generator.lua` (generator calls validator).
- Update `systems/cave_generator.lua` to call validator on each new chunk, retrying up to `MAX_GEN_RETRIES` times before falling back to a known-safe straight corridor chunk.

Out of scope: rendering, real-time gameplay. This is a pure data system.

#### Expected files to change

```
systems/cave_validator.lua  (new — reachability simulation)
systems/cave_generator.lua  (updated — call validator per chunk, retry logic, fallback chunk)
constants.lua               (updated — VALIDATION_MARGIN, MAX_GEN_RETRIES, FALLBACK_GAP)
test/validator_test.lua     (new — debug harness testing known-feasible and known-infeasible chunks)
```

#### Dependencies

- Phase 3 complete — movement constants (`RISE_ACC`, `FALL_ACC`, `MAX_VY_UP`, `MAX_VY_DOWN`, fixed timestep) must be finalized.
- Phase 4 complete — generator exists and produces slice data.
- The validator must import the same constants as `player.lua`. If constants change in Phase 3, the validator must be updated immediately.

#### Risks

**High.** This is the most algorithmically complex component. Failure modes:
- Validator is too strict: rejects all reasonable chunks, generator infinite-loops (mitigated by `MAX_GEN_RETRIES` and fallback).
- Validator is too loose: allows passages the player cannot actually traverse (mitigated by using identical constants and safety margin).
- State explosion: if the state space is too large, validation is slow. Mitigate by discretizing `vy` into a bounded range and capping the state set size.

Test this phase thoroughly before proceeding to rendering.

#### Tests and checks to run

- Unit test: a chunk with a very large gap and no wall changes → must return `true`.
- Unit test: a chunk with `topY == bottomY` (zero-width passage) → must return `false`.
- Unit test: a chunk that requires sustained upward movement with full rise acceleration → must return `true` if gap is achievable, `false` if not.
- Run generator with validator enabled for 1000 chunks — confirm no infinite loop and no Lua stack overflow.
- Print rejected chunk count over 1000 chunks — if rejection rate > 50%, MIN_GAP or MAX_STEP constants need tuning.
- Grep `validator.lua` for any direct reference to `math.random` — must return zero (validator is deterministic given its inputs).

#### Review check before moving work to `DONE.md`

- [ ] Validator uses exactly the same constants as `player.lua` (confirmed by import or shared `constants.lua`).
- [ ] Safety margin is applied by shrinking usable gap, not by changing avatar size in gameplay.
- [ ] Fallback chunk is a known-safe straight corridor, not another randomly generated chunk.
- [ ] Max retry count is enforced and fallback is triggered correctly.
- [ ] Test harness covers at least: trivially feasible, trivially infeasible, and one realistic gameplay chunk.
- [ ] Validator does not import any display or rendering module.
- [ ] Performance: 1000 chunk validation completes in < 2 seconds on the development machine.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 5

- [ ] Create systems/cave_validator.lua with validator.check(slices, params) function
- [ ] Implement discrete reachability simulation with (y, vy) state set per slice
- [ ] Apply VALIDATION_MARGIN by shrinking usable gap during simulation
- [ ] Update cave_generator.lua to call validator per chunk with retry loop
- [ ] Implement fallback straight-corridor chunk in cave_generator.lua
- [ ] Add VALIDATION_MARGIN, MAX_GEN_RETRIES, FALLBACK_GAP to constants.lua
- [ ] Write test harness: trivially feasible chunk → must return true
- [ ] Write test harness: trivially infeasible chunk → must return false
- [ ] Write test harness: 1000 chunk generation loop → no infinite loop, no errors
- [ ] Check rejection rate over 1000 chunks — tune constants if > 50%
- [ ] Grep validator.lua for math.random (must return 0 matches)
- [ ] Confirm validator runs < 2s for 1000 chunks
```

#### Exit criteria for moving items to `DONE.md`

- `systems/cave_validator.lua` exists and implements reachability simulation.
- `cave_generator.lua` calls validator and retries up to `MAX_GEN_RETRIES`.
- All three unit tests pass (feasible, infeasible, realistic).
- 1000-chunk generation loop completes without error and without infinite loop.
- Rejection rate < 50% with current constants (adjust constants if needed before marking done).

---

### Phase 6 — Cave rendering, scrolling, and collision detection

#### Goal

The cave scrolls smoothly on screen. Cave slices are rendered as blocky rectangles. Off-screen slices are recycled. Collision between the avatar and cave walls is detected correctly and triggers a transition to the game-over scene.

#### Scope

- Implement cave rendering in `scenes/game.lua`:
  - Maintain an active pool of display objects for cave slices (top block + bottom block per slice).
  - Each frame: shift slice x positions left by `SCROLL_SPEED * dt`, recycle slices that exit left edge, append new chunks as needed.
  - Rendering: `display.newRect()` for each wall block, blocky retro color.
- Implement `systems/collision.lua`:
  - `collision.check(playerRect, activeSlices)` returns `true` if avatar overlaps any wall block.
  - Uses manual AABB check against the slice the avatar is currently aligned with.
- Wire collision into `scenes/game.lua` enterFrame: if collision detected, stop game loop, go to gameover scene.
- Cave slices must be generated ahead (look-ahead buffer) and validated before appearing on screen.

Out of scope: score (Phase 8), trail (Phase 7), full UI (Phase 9).

#### Expected files to change

```
systems/collision.lua     (new — AABB collision check against active cave slice)
scenes/game.lua           (updated — cave rendering loop, slice pool, scroll, collision check)
constants.lua             (updated — SLICE_WIDTH, WALL_COLOR, BG_COLOR, LOOKAHEAD_CHUNKS, AVATAR_COLOR)
```

#### Dependencies

- Phase 3 complete (player renders and moves).
- Phase 4 complete (generator produces slice data).
- Phase 5 complete (validator integrated into generator).
- `constants.lua` settled from Phases 3–5.

#### Risks

**Medium.** Slice recycling (object pooling) is the main risk: if slice display objects are not correctly reset and repositioned, visual artifacts appear. Test by watching for ghost blocks or flickering.

Performance risk: creating/destroying display objects every frame tanks FPS. The pool must be correctly sized to cover the visible area plus look-ahead buffer. Mitigate by sizing pool = `math.ceil(SCREEN_W / SLICE_WIDTH) + CHUNK_SIZE * LOOKAHEAD_CHUNKS`.

HTML5 risk: canvas rendering performance at 60 FPS with many display objects — verify in browser early.

#### Tests and checks to run

- Simulator: cave scrolls continuously for 60 seconds without frame rate drop below 55 FPS.
- Simulator: avatar touching top wall → game transitions to gameover scene.
- Simulator: avatar touching bottom wall → game transitions to gameover scene.
- Simulator: avatar in center of passage for 30 seconds → no false-positive collision.
- HTML5 browser: same three manual tests.
- Visual check: no ghost blocks, no flickering, no slice gaps at chunk boundaries.
- Visual check: cave looks blocky-retro (no smooth curves).

#### Review check before moving work to `DONE.md`

- [ ] Display object pool is correctly sized and reuses objects (no new rect each frame).
- [ ] Collision uses AABB, not Box2D physics.
- [ ] Look-ahead buffer ensures cave is always generated and validated before scrolling into view.
- [ ] Chunk boundaries are visually seamless.
- [ ] Collision detection has no false positives on a 30-second center-passage test.
- [ ] `systems/collision.lua` has no display or rendering code — pure geometry check.
- [ ] No score, trail, or full UI added yet (scope check).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 6

- [ ] Create systems/collision.lua with AABB check against current cave slice
- [ ] Implement slice display object pool in scenes/game.lua
- [ ] Implement per-frame scroll: shift all active slices left by SCROLL_SPEED
- [ ] Implement slice recycling: move off-screen slices to pool, request new chunk
- [ ] Implement look-ahead buffer: maintain LOOKAHEAD_CHUNKS of pre-generated validated chunks
- [ ] Integrate collision.check() in enterFrame; trigger gameover on collision
- [ ] Add SLICE_WIDTH, WALL_COLOR, BG_COLOR, AVATAR_COLOR, LOOKAHEAD_CHUNKS to constants.lua
- [ ] Test: cave scrolls 60 seconds at >= 55 FPS in simulator
- [ ] Test: top-wall collision triggers gameover transition
- [ ] Test: bottom-wall collision triggers gameover transition
- [ ] Test: 30-second center-passage survival, no false collision
- [ ] Test: all three above in HTML5 browser build
- [ ] Visual check: no ghost blocks, no flickering, seamless chunk joins
```

#### Exit criteria for moving items to `DONE.md`

- Cave scrolls in both simulator and browser without visual artifacts.
- Collision triggers gameover on wall contact (top and bottom tested).
- No false-positive collision over 30-second center run.
- FPS >= 55 in simulator over 60-second run.
- No new display objects created per frame (pool confirmed by adding a creation counter).

---

### Phase 7 — Trail rendering (chain of small blocks)

#### Goal

`systems/trail.lua` maintains a bounded circular buffer of recent player positions and renders them as a chain of small square blocks that scroll with the world and fade off the left edge naturally.

#### Scope

- Implement `systems/trail.lua`:
  - Circular buffer of the last `TRAIL_LENGTH` player world-space positions.
  - Pool of small `display.newRect()` square blocks.
  - Each frame: push current player position, pop oldest if buffer full.
  - Render each buffer entry as a small square at its current screen position (shifted by same scroll offset as cave).
  - Blocks that scroll off-screen left are hidden or removed from pool.
- Integrate into `scenes/game.lua`.
- Trail color must be distinct from avatar and cave wall.

Out of scope: trail collision physics. Trail is visual only.

#### Expected files to change

```
systems/trail.lua         (new — circular buffer, block pool, render)
scenes/game.lua           (updated — instantiate trail, call trail:update() and trail:render() in enterFrame)
constants.lua             (updated — TRAIL_LENGTH, TRAIL_BLOCK_SIZE, TRAIL_COLOR, TRAIL_SPACING)
```

#### Dependencies

- Phase 3 complete (player position is available).
- Phase 6 complete (scroll offset is tracked per frame — trail must use same scroll reference).

#### Risks

**Low-medium.** Trail block count must be bounded. Risk: trail grows unbounded, tanks FPS. Mitigate: circular buffer with hard `TRAIL_LENGTH` cap. All pool objects pre-allocated at scene start.

Visual risk: trail blocks overlap if player moves slowly; trail has gaps if player moves fast. Both are acceptable per REQUIREMENTS.md ("sequence of small rectangular or square samples"). Document acceptable visual behavior.

#### Tests and checks to run

- Simulator: trail appears behind avatar and scrolls left with the cave.
- Simulator: trail blocks stop appearing after death (trail frozen on game-over).
- Simulator: 60-second run — no FPS degradation from trail (compare FPS with/without trail).
- HTML5: same behavior in browser.
- Visual check: trail is a chain of small squares, blocky retro style, distinct color from avatar and walls.
- Verify trail pool does not grow beyond `TRAIL_LENGTH` blocks (add counter assertion in debug).

#### Review check before moving work to `DONE.md`

- [ ] Trail uses pre-allocated display object pool, no per-frame `display.newRect()`.
- [ ] Circular buffer is correctly bounded at `TRAIL_LENGTH`.
- [ ] Trail scrolls identically to cave (uses same scroll offset).
- [ ] Trail stops updating on game-over.
- [ ] Trail color, size, spacing in `constants.lua`.
- [ ] No gameplay or score code added (scope check).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 7

- [ ] Create systems/trail.lua with circular position buffer and block pool
- [ ] Pre-allocate TRAIL_LENGTH display blocks at scene start
- [ ] Implement trail:update(playerX, playerY, scrollOffset) to push new position
- [ ] Implement trail:render() to position each block at its screen-space coordinate
- [ ] Hide or recycle trail blocks that scroll off-screen left
- [ ] Add TRAIL_LENGTH, TRAIL_BLOCK_SIZE, TRAIL_COLOR, TRAIL_SPACING to constants.lua
- [ ] Integrate trail into scenes/game.lua enterFrame
- [ ] Freeze trail updates on game-over
- [ ] Test: trail appears and scrolls correctly in simulator (60s run)
- [ ] Test: trail in HTML5 browser build
- [ ] Test: trail pool size stays bounded (add debug counter)
- [ ] FPS comparison test: measure FPS with trail vs without trail in simulator
- [ ] Visual check: trail is blocky, distinct from walls and avatar
```

#### Exit criteria for moving items to `DONE.md`

- `systems/trail.lua` exists with circular buffer and pre-allocated pool.
- Trail scrolls correctly and is visually distinct.
- Trail pool bounded (confirmed by debug counter).
- No FPS degradation > 5 FPS attributable to trail.
- Trail works identically in simulator and HTML5 browser.

---

### Phase 8 — Score tracking and local persistence

#### Goal

`systems/score.lua` tracks elapsed survival time per run. `systems/save.lua` saves and loads best score to/from device local storage. Both work on HTML5 and Android.

#### Scope

- Implement `systems/score.lua`:
  - Start timer on game start (wall-clock reference, not frame count).
  - Stop timer on game-over.
  - Return elapsed time in milliseconds.
  - Format for display: whole seconds or one decimal place.
- Implement `systems/save.lua`:
  - `save.loadBestTime()` returns stored best time or 0.
  - `save.saveBestTime(time)` persists new best.
  - Uses `json` library and `io` with `system.DocumentsDirectory` path to write a JSON file.
- Integrate into `scenes/game.lua` (start/stop timer, compare to best on game-over, save if new best).
- Integrate read into `scenes/menu.lua` and `scenes/gameover.lua` for display.

Out of scope: full UI (next phase). Score values are computed here; display wiring happens in Phase 9.

#### Expected files to change

```
systems/score.lua         (new — time tracking, formatting)
systems/save.lua          (new — JSON save/load via DocumentsDirectory)
scenes/game.lua           (updated — start/stop score, compare and save best on death)
scenes/menu.lua           (updated — load and store best time for later display)
scenes/gameover.lua       (updated — receive current time and best time for display)
```

#### Dependencies

- Phase 2 complete (scenes exist as stubs).
- Phase 6 complete (game-over event is triggered by collision).

#### Risks

**Low-medium.** HTML5 persistence via `system.DocumentsDirectory` + `io.open` must be verified in browser — some Solar2D HTML5 builds use localStorage or emscripten virtual filesystem. If `io.open` fails silently in HTML5, best score will not persist. Test this explicitly.

Android risk is low — `system.DocumentsDirectory` is well-supported natively.

#### Tests and checks to run

- Simulator: survive 10 seconds, verify score displays as ~10.0.
- Simulator: die, verify best score is saved; restart, verify best score loads correctly.
- Simulator: die with a lower score than previous best — verify best is NOT overwritten.
- HTML5: survive and die — verify best score persists after browser page refresh.
- Android (if available at this phase): same persistence test via APK.
- Edge case: first run ever (no save file) — verify `save.loadBestTime()` returns 0 without error.

#### Review check before moving work to `DONE.md`

- [ ] Timer uses wall-clock time reference, not frame counter.
- [ ] Save file is written to `system.DocumentsDirectory`, not `system.ResourceDirectory`.
- [ ] Best score is only updated when new score > old best.
- [ ] First-run (no save file) case handled without error.
- [ ] HTML5 persistence test completed and documented in `DEV_NOTES.md`.
- [ ] No UI layout changes (scope check — display wiring is Phase 9).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 8

- [ ] Create systems/score.lua with start/stop/getElapsed/format functions
- [ ] Implement score timer using system.getTimer() or os.time() for wall-clock reference
- [ ] Create systems/save.lua with loadBestTime() and saveBestTime(time) using JSON file
- [ ] Handle first-run case: no save file → return 0 without error
- [ ] Integrate score start into scenes/game.lua on scene show
- [ ] Integrate score stop and best-time comparison into game-over trigger in scenes/game.lua
- [ ] Call save.saveBestTime() only when new time > current best
- [ ] Pass current time and best time to gameover scene
- [ ] Load best time in menu scene for later display use
- [ ] Test: 10s survival → score shows ~10.0 in simulator
- [ ] Test: die, restart, verify best score loads correctly in simulator
- [ ] Test: die with lower score, verify best NOT overwritten
- [ ] Test: first run (no save file) starts cleanly
- [ ] Test: HTML5 browser → best score persists after page refresh
- [ ] Document HTML5 persistence behavior in DEV_NOTES.md
```

#### Exit criteria for moving items to `DONE.md`

- `systems/score.lua` and `systems/save.lua` exist with required functions.
- All five manual tests pass in simulator.
- HTML5 persistence test passes (score survives page refresh).
- First-run case handled cleanly.

---

### Phase 9 — Full game flow integration (title, gameplay, game-over, restart)

#### Goal

All systems are wired together into a complete, playable game loop. The title screen shows the best time. The HUD shows live score. The game-over screen shows current and best time. Restart works cleanly with no leaked state.

#### Scope

- Complete `scenes/menu.lua`:
  - Show "CoolCave" title, start prompt, best survival time.
  - Tap/click starts game.
- Complete `scenes/game.lua`:
  - HUD: live score display in corner, readable in landscape.
  - All systems initialized cleanly on scene show: player, cave generator, cave renderer, trail, score, input.
  - All systems cleaned up completely on scene destroy (no display object leaks, no dangling listeners).
- Complete `scenes/gameover.lua`:
  - Show current time, best time, restart prompt.
  - Tap/click navigates back to menu.
- First run and every restart begins with the same fixed seed (from `constants.lua`).
- Confirm cave continues to scroll correctly through multiple restarts.

#### Expected files to change

```
scenes/menu.lua           (updated — best time display, start navigation)
scenes/game.lua           (updated — HUD label, full system init/cleanup, restart-clean state)
scenes/gameover.lua       (updated — current and best time display, restart navigation)
constants.lua             (updated — DEFAULT_SEED value)
```

#### Dependencies

- All of Phases 3–8 complete and passing exit criteria.
- All systems (player, cave, validator, trail, score, save) implemented and tested in isolation.

#### Risks

**Medium.** State leakage between runs is the main risk: display objects not removed, event listeners accumulating, RNG state not reset. Mitigate by:
- Explicitly removing all display group children in `scene:destroy()`.
- Re-constructing all system instances fresh in `scene:create()` or `scene:show()`.
- Resetting the cave generator with the fixed seed on every game start.

A second restart bug risk: the cave's pre-generated look-ahead buffer must be cleared and re-seeded on restart, not carried over from the previous run.

#### Tests and checks to run

- Simulator: full run from launch → title → game → die → game-over → restart → title → game (two full cycles).
- Verify: each restart begins the same cave (fixed seed).
- Verify: best time on title screen reflects actual best time after two runs.
- Verify: after 5 rapid restarts, no Lua errors and no FPS degradation (listener leak test).
- Verify: HUD score is readable and does not overlap the cave passage.
- HTML5: full two-cycle run in browser.
- Manual play test: complete 30-second survival run feels coherent.

#### Review check before moving work to `DONE.md`

- [ ] Scene lifecycle: all display objects and listeners created in `show` are removed in `destroy`.
- [ ] Cave generator is re-initialized with fixed seed on every new game start.
- [ ] Look-ahead buffer is cleared and refilled on restart.
- [ ] Title screen shows correct best time (loaded from save).
- [ ] Game-over screen shows correct current and best time.
- [ ] HUD label does not overlap cave passage in landscape layout.
- [ ] Five rapid restarts cause no errors and no FPS drop.
- [ ] No features beyond MVP scope added.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 9

- [ ] Complete scenes/menu.lua: show best time from save, add start navigation
- [ ] Complete scenes/gameover.lua: show current and best time, add restart navigation
- [ ] Add HUD score label to scenes/game.lua, update each frame
- [ ] Wire all systems (player, cave, trail, score) into game scene init
- [ ] Wire full system cleanup into scene:destroy() in game scene
- [ ] Reset cave generator with fixed seed (DEFAULT_SEED) on every game start
- [ ] Clear look-ahead buffer and refill on restart
- [ ] Test: two full launch → play → die → restart cycles in simulator
- [ ] Test: each restart starts with same cave layout (fixed seed verification)
- [ ] Test: best time reflects actual best after two runs on menu and gameover screens
- [ ] Test: 5 rapid restarts — no Lua errors, no FPS degradation
- [ ] Test: HUD score readable, does not overlap cave in landscape
- [ ] Test: full two-cycle run in HTML5 browser
- [ ] Manual 30s play test: game feels coherent and complete
```

#### Exit criteria for moving items to `DONE.md`

- All three scenes complete and navigable.
- Two full play cycles pass in simulator and browser without errors.
- Fixed seed verified: two runs produce identical cave layouts.
- Five rapid restarts cause no errors or performance degradation.
- HUD readable in landscape.
- Best time persistence verified across app restart.

---

### Phase 10 — Audio integration with HTML5 compatibility

#### Goal

Sound effects are implemented for game start and collision/death. Audio works on HTML5 (with AudioContext resume after user gesture) and in the simulator. Audio is non-blocking: if audio fails to load, the game continues silently.

#### Scope

- Add short audio files: `assets/audio/start.ogg`, `assets/audio/hit.ogg`.
- Implement audio loading and playback in relevant scenes.
- Apply HTML5 AudioContext fix: resume AudioContext on first user gesture (the same tap that starts the game).
- If ambient audio is included, it must be a very short looping clip (HTML5 limitation: large files fail to load).
- `save.lua` saves/loads sound enabled/disabled preference.
- Optional: sound toggle on title screen.

Out of scope: background music (deferred until HTML5 audio is confirmed reliable for that use case).

#### Expected files to change

```
assets/audio/start.ogg    (new — short game start sound, < 100KB)
assets/audio/hit.ogg      (new — short collision sound, < 100KB)
scenes/menu.lua           (updated — audio resume on first tap, optional sound toggle)
scenes/game.lua           (updated — play start sound on game begin, play hit sound on collision)
systems/save.lua          (updated — add soundEnabled save/load)
constants.lua             (updated — AUDIO_ENABLED default)
```

#### Dependencies

- Phase 9 complete (full game flow working).
- Audio files must exist before this phase begins.

#### Risks

**Medium for HTML5.** Known Solar2D HTML5 audio limitations:
- AudioContext requires user gesture before playback starts — the start tap must explicitly call `audio.resume()` or equivalent.
- Large audio files fail silently.
- `Event.completed` callback always returns false in HTML5.

Mitigate by: using short clips only, adding `audio.resume()` on the first input event, wrapping all audio calls in `pcall` or nil-checks so audio failure never crashes the game.

Native Android risk is low.

#### Tests and checks to run

- Simulator: start sound plays on game begin; hit sound plays on collision.
- HTML5 browser: start sound plays on first game start (tap triggers AudioContext resume).
- HTML5 browser: hit sound plays on collision.
- HTML5 browser: sounds work after page reload (no persistent AudioContext state assumed).
- Test with sound disabled: game runs silently, no errors.
- Test: if audio file missing or fails to load, game continues without crash.

#### Review check before moving work to `DONE.md`

- [ ] Both audio files are short (< 100KB each).
- [ ] AudioContext resume is called on first user gesture in HTML5.
- [ ] All audio calls wrapped safely so failure does not crash the game.
- [ ] Sound preference persists across restarts.
- [ ] No background music added that would fail HTML5 load (scope check).
- [ ] Audio works in simulator and HTML5 browser.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 10

- [ ] Source or create assets/audio/start.ogg (< 100KB)
- [ ] Source or create assets/audio/hit.ogg (< 100KB)
- [ ] Load audio files in scenes/game.lua; wrap in pcall/nil-check
- [ ] Play start.ogg on game begin in scenes/game.lua
- [ ] Play hit.ogg on collision in scenes/game.lua
- [ ] Add audio.resume() call on first user gesture (menu start tap) for HTML5
- [ ] Add soundEnabled preference to systems/save.lua (load/save)
- [ ] Respect soundEnabled when playing sounds (skip playback if disabled)
- [ ] Test: start and hit sounds play in simulator
- [ ] Test: start and hit sounds play in HTML5 browser after start tap
- [ ] Test: game runs without error when audio files are missing (remove files temporarily)
- [ ] Test: sound-disabled preference persists across restarts
```

#### Exit criteria for moving items to `DONE.md`

- Both audio files exist and are < 100KB.
- Sounds play correctly in simulator and HTML5 browser.
- Game survives missing audio files without crashing.
- Sound preference persists.
- AudioContext resume is in place for HTML5.

---

### Phase 11 — HTML5 verification, polish, and browser sign-off

#### Goal

The HTML5 build is fully verified in Chrome and Firefox. Scaling, input, audio, and performance meet requirements. A public-ready HTML5 build can be produced.

#### Scope

- Verify canvas scaling behavior at different browser window sizes (letterbox expected).
- Verify mouse input (hold/release) matches expected behavior in both Chrome and Firefox.
- Verify keyboard input (space = rise) works as debug convenience.
- Test 60-second survival run in both browsers — FPS must remain playable.
- Verify best-score persistence after page refresh in both browsers.
- Verify no JavaScript console errors under normal gameplay.
- Verify audio in both browsers.
- Fix any HTML5-specific rendering or input issues discovered.
- Document the final HTML5 build output location and serving instructions in `DEV_NOTES.md`.

Out of scope: online hosting, CDN, or deployment to a public URL. This phase is local verification only.

#### Expected files to change

```
scenes/game.lua           (possibly updated — HTML5-specific input or audio fixes)
scenes/menu.lua           (possibly updated — HTML5-specific fixes)
config.lua                (possibly updated — scaling adjustments for browser)
DEV_NOTES.md              (updated — HTML5 build output path, serve command, browser test checklist)
```

#### Dependencies

- Phase 10 complete (audio integrated).
- All prior phases passing exit criteria.

#### Risks

**Medium.** Browser-specific quirks may require targeted fixes not anticipated during development. FPS in HTML5 canvas mode may be lower than native. If 60 FPS is not achievable in HTML5, document the actual FPS and whether gameplay remains acceptable.

#### Tests and checks to run

- HTML5 in Chrome: full two-cycle play test (launch → play → die → restart).
- HTML5 in Firefox: full two-cycle play test.
- Canvas scaling: resize browser window — canvas must letterbox correctly, no distortion.
- Mouse hold/release in Chrome: avatar rises and falls correctly.
- Mouse hold/release in Firefox: avatar rises and falls correctly.
- Space key in Chrome: rises correctly (debug convenience).
- Audio in Chrome and Firefox.
- Best score persistence after page refresh in Chrome.
- JavaScript console: zero errors during normal gameplay.
- FPS measurement: add temporary FPS display, verify >= 50 FPS in both browsers.

#### Review check before moving work to `DONE.md`

- [ ] Both Chrome and Firefox pass all manual tests.
- [ ] No JavaScript console errors.
- [ ] Canvas letterboxes correctly at different window sizes.
- [ ] FPS >= 50 in both browsers (or documented degradation with justification).
- [ ] Audio works in both browsers.
- [ ] `DEV_NOTES.md` updated with final HTML5 build and serve instructions.
- [ ] No Android-specific code added in this phase (scope check).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 11

- [ ] Build HTML5 output via Solar2D HTML5 build target
- [ ] Serve HTML5 build locally with python3 -m http.server 8000
- [ ] Chrome: full two-cycle play test (launch → play → die → restart → play → die)
- [ ] Firefox: full two-cycle play test
- [ ] Chrome: canvas scaling at narrow, normal, and wide browser widths
- [ ] Firefox: canvas scaling at narrow, normal, and wide browser widths
- [ ] Chrome: mouse hold/release input verification
- [ ] Firefox: mouse hold/release input verification
- [ ] Chrome + Firefox: space key rises avatar
- [ ] Chrome + Firefox: audio plays correctly
- [ ] Chrome: best score persists after page refresh
- [ ] Chrome + Firefox: zero JS console errors during gameplay
- [ ] Add temporary FPS display and measure in both browsers (>= 50 FPS required)
- [ ] Remove temporary FPS display after measurement
- [ ] Fix any HTML5-specific issues found during testing
- [ ] Update DEV_NOTES.md with final HTML5 build path and serve command
```

#### Exit criteria for moving items to `DONE.md`

- Full two-cycle test passes in Chrome and Firefox with zero JS console errors.
- Canvas scales correctly at multiple window sizes.
- FPS >= 50 in both browsers (or acceptable degradation documented).
- Audio works in both browsers.
- `DEV_NOTES.md` updated.

---

### Phase 12 — Android build pipeline and device verification

#### Goal

A working Android APK is produced from the Solar2D project, installs on an Android device, and passes all core gameplay tests via touch input.

#### Scope

- Configure `build.settings` for Android:
  - Package name and version code.
  - Minimum SDK version.
  - Landscape orientation lock.
  - Icon placeholder if required by build.
- Set up debug keystore for development builds.
- Produce a debug APK via Solar2D Android build.
- Install APK on an Android device or emulator.
- Verify touch input (press/hold to rise, release to fall) on device.
- Verify cave rendering and scrolling.
- Verify trail rendering.
- Verify score and best score persistence on device.
- Verify audio on device.
- Verify game-over and restart work correctly on device.

Out of scope: Google Play submission, release keystore signing, Play Store listing. Those are post-MVP activities.

#### Expected files to change

```
build.settings            (updated — Android package, versionCode, minSdkVersion, icon config)
assets/icon/              (new if required — placeholder launcher icon, 512×512 PNG)
DEV_NOTES.md              (updated — Android build steps, keystore command, ADB install command)
```

#### Dependencies

- Phase 11 complete (HTML5 fully verified — Android build uses the same codebase).
- Android SDK installed on the development machine (A4).
- Android device or emulator available.

#### Risks

**Medium.** Build configuration errors (wrong package name, missing keystore, incorrect SDK version) are common first-time issues. Mitigate by following Solar2D Android build documentation exactly and verifying each build step in `DEV_NOTES.md`.

Touch input risk: low — Solar2D normalizes touch events across Android versions.

Performance risk: if 60 FPS was not achievable in HTML5, Android native should be faster — verify independently.

#### Tests and checks to run

- Android build via Solar2D: produces an APK without build errors.
- ADB install: APK installs successfully on device.
- Device: app launches in landscape orientation.
- Device: touch hold → avatar rises; release → avatar falls.
- Device: cave scrolls, trail appears, collision works.
- Device: game-over screen appears on collision, shows correct scores.
- Device: restart works, cave resets to fixed seed.
- Device: best score persists after force-quit and relaunch.
- Device: audio plays (start and hit sounds).
- Device: 60-second survival run — no crash, no visible FPS drop.

#### Review check before moving work to `DONE.md`

- [ ] `build.settings` has correct package name, versionCode, and minSdkVersion.
- [ ] Debug keystore is documented but NOT committed to git.
- [ ] APK builds without errors.
- [ ] All device tests pass.
- [ ] Best score persists after force-quit on device.
- [ ] `DEV_NOTES.md` updated with Android build and install steps.
- [ ] Release keystore NOT required for this phase — that is a post-MVP task.

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 12

- [ ] Update build.settings with Android package name, versionCode 1, minSdkVersion 21
- [ ] Add launcher icon placeholder to assets/icon/ (512x512 PNG)
- [ ] Set up debug keystore (document command in DEV_NOTES.md, do NOT commit keystore to git)
- [ ] Add debug.keystore to .gitignore
- [ ] Produce debug APK via Solar2D Android build
- [ ] Install APK on Android device via adb install
- [ ] Device test: app launches in landscape
- [ ] Device test: touch hold/release input works correctly
- [ ] Device test: cave scrolling, trail, collision all work
- [ ] Device test: game-over screen shows correct scores
- [ ] Device test: restart resets cave to fixed seed
- [ ] Device test: best score persists after force-quit and relaunch
- [ ] Device test: start and hit sounds play
- [ ] Device test: 60s survival run, no crash
- [ ] Update DEV_NOTES.md with Android build steps and ADB install command
```

#### Exit criteria for moving items to `DONE.md`

- APK builds without errors.
- APK installs and launches on Android device.
- All device gameplay tests pass.
- Best score persists after force-quit.
- `DEV_NOTES.md` contains Android build and install steps.
- Debug keystore is NOT in the git repository.

---

### Phase 13 — Stabilization and final review

#### Goal

The game is complete, stable, and matches all MVP requirements in REQUIREMENTS.md. All known issues are resolved or explicitly documented as post-MVP. `TODO.md` is empty or contains only post-MVP items. `DONE.md` reflects the complete delivered scope.

#### Scope

- Full regression test across simulator, HTML5 (Chrome + Firefox), and Android device.
- Resolve any remaining bugs found in prior phases.
- Verify all REQUIREMENTS.md MVP items are implemented.
- Sweep for: Lua errors in console, memory leaks across 10 restarts, FPS regressions.
- Ensure all post-MVP items (obstacles, multiple modes, online leaderboard, etc.) are listed in `DONE.md` or a backlog note, not accidentally implemented.
- Clean up any debug prints, test harnesses, or temporary code.
- Final review of all constants in `constants.lua` for gameplay feel.
- Update `DEV_NOTES.md` with final state.

#### Expected files to change

```
Any file from Phases 1–12 — bug fixes and cleanup only
constants.lua             (final tuning pass)
DEV_NOTES.md              (final state documentation)
DONE.md                   (updated to reflect completed MVP)
TODO.md                   (cleared or post-MVP only)
```

#### Dependencies

- All prior phases complete and passing exit criteria.

#### Risks

**Low.** This is stabilization, not new development. Main risk: undiscovered platform-specific bugs found during regression. If a new bug is found, fix it in this phase — do not defer.

#### Tests and checks to run

- Simulator: 10 complete restarts — no Lua errors, no FPS degradation across restarts.
- HTML5 Chrome: full two-cycle gameplay test.
- HTML5 Firefox: full two-cycle gameplay test.
- Android: full play session (3 runs, best score update confirmed).
- Cross-check every MVP requirement in REQUIREMENTS.md against current implementation.
- Grep for `print(` and `-- DEBUG` — all debug artifacts must be removed.
- Grep for `math.random` in non-stdlib contexts — must be zero in game systems.
- Visual review: blocky retro art style consistent across all elements.

#### Review check before moving work to `DONE.md`

- [ ] Every REQUIREMENTS.md MVP item has a corresponding implementation verified.
- [ ] No post-MVP features accidentally included.
- [ ] All debug prints and test harnesses removed from shipped code.
- [ ] `TODO.md` contains only post-MVP backlog items.
- [ ] `DONE.md` reflects the complete delivered scope.
- [ ] No Lua errors across 10 restarts in simulator.
- [ ] `constants.lua` values feel correct for gameplay (final tuning sign-off).

#### Exact `TODO.md` entries to refresh from this phase

```
## Phase 13

- [ ] Full regression: 10 restarts in simulator, no errors, no FPS drop
- [ ] Full regression: two-cycle play test in Chrome
- [ ] Full regression: two-cycle play test in Firefox
- [ ] Full regression: three runs on Android device, best score updates correctly
- [ ] Cross-check every REQUIREMENTS.md MVP item against implementation
- [ ] Remove all debug print() statements and -- DEBUG comments from shipped code
- [ ] Grep for math.random in game systems (must return 0 matches)
- [ ] Final gameplay feel review: tune constants.lua values if needed
- [ ] Update DONE.md to reflect completed MVP scope
- [ ] Confirm TODO.md contains only post-MVP items
- [ ] Update DEV_NOTES.md with final project state
```

#### Exit criteria for moving items to `DONE.md`

- All REQUIREMENTS.md MVP items verified as implemented.
- Zero Lua errors across 10 restarts in simulator.
- Zero JS console errors in Chrome and Firefox.
- Android device passes all gameplay tests.
- All debug artifacts removed (grep confirmed).
- `DONE.md` and `TODO.md` are accurate and up to date.

---

## Dependency notes

```
Phase 1 ─────────────────────────────────────┐
Phase 2 (requires Phase 1) ──────────────────┤
Phase 3 (requires Phase 2) ──────────────────┤
Phase 4 (requires Phase 1; constants from 3) ─┤
Phase 5 (requires Phase 3 + Phase 4) ─────────┤
Phase 6 (requires Phase 3 + Phase 4 + Phase 5)┤
Phase 7 (requires Phase 3 + Phase 6) ─────────┤
Phase 8 (requires Phase 2 + Phase 6) ─────────┤
Phase 9 (requires Phases 3–8) ────────────────┤
Phase 10 (requires Phase 9) ──────────────────┤
Phase 11 (requires Phase 10) ─────────────────┤
Phase 12 (requires Phase 11) ─────────────────┤
Phase 13 (requires Phase 12) ─────────────────┘
```

**Critical path:** 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13.

All phases are sequential. No phase is safely parallelizable without accepting the risk of rework, because later phases depend on constants and movement model decisions made in earlier phases.

**Key shared dependency:** `constants.lua` is a shared contract. Any change to movement constants (`RISE_ACC`, `FALL_ACC`, `MAX_VY_UP`, `MAX_VY_DOWN`) after Phase 5 requires re-running the validator test harness to confirm feasibility guarantees still hold.

---

## Review policy

**Expected review size:** Each phase should produce no more than ~300 lines of new Lua code (excluding comments and blank lines). Configuration files, constants, and test harnesses do not count toward this limit.

**Split requirement:** If a phase is estimated to exceed ~300 lines of new logic before implementation starts, it must be split into two phases before proceeding. Do not start implementation of an oversized phase.

**Oversized phase rule:** An oversized phase may not proceed unchanged. It must be split, reviewed as two separate items, and each sub-phase must have its own exit criteria.

**Review gate:** No phase may be marked complete in `DONE.md` until all exit criteria are binary-verified. "Mostly working" is not done. An item that is partially complete must remain in `TODO.md`.

**Regression policy:** If a later phase introduces a regression in an earlier system, the regression must be fixed before the later phase can be marked done.

---

## Definition of done for the plan

The project is complete when all of the following are true:

1. **Implementation:** All MVP systems from REQUIREMENTS.md are implemented: avatar with floaty kinematics, deterministic seeded cave generator, feasibility validator, cave renderer with recycled slice pool, trail as chain of small blocks, collision detection, time-based score, local persistence of best score, title screen, game-over screen, restart.
2. **HTML5:** The game runs correctly in Chrome and Firefox via a local HTTP server. Zero JavaScript console errors. Canvas scales correctly. Mouse input works. Audio plays. Best score persists after page refresh.
3. **Android:** A debug APK installs and runs on an Android device. Touch input, cave rendering, trail, collision, score, persistence, and audio all work on device.
4. **Determinism:** Same fixed seed produces identical cave layouts across multiple runs, verified by observation.
5. **Performance:** >= 55 FPS in Solar2D simulator over a 60-second run; >= 50 FPS in Chrome and Firefox; no visible FPS drop on Android device.
6. **Stability:** Zero Lua errors across 10 restarts in simulator. Zero JS errors during normal gameplay in browser.
7. **Cleanup:** No debug prints, test harnesses, or temporary code in shipped files. `math.random` is not used in any game system.
8. **Documentation:** `DEV_NOTES.md` documents the full local build and test workflow for both HTML5 and Android. `DONE.md` reflects the complete delivered scope. `TODO.md` contains only post-MVP items.
9. **Scope:** No post-MVP features (obstacles, multiple modes, online leaderboard, power-ups, skins) have been implemented.

---

## Open questions

All blocking questions are resolved. Non-blocking questions have concrete answers recorded below.

### Blocking before Phase 1 — RESOLVED

| # | Question | Resolution |
|---|---|---|
| OQ1 | Is Solar2D installed on the development machine? | **Yes.** Solar2D is installed on Windows. Phase 1 unblocked. |
| OQ2 | Is the Android SDK configured and is a device or emulator available? | **SDK: yes, installed on Windows.** Confirm a device or AVD emulator is reachable via `adb devices` before Phase 12. |

### Non-blocking — RESOLVED

| # | Question | Resolution | Affects |
|---|---|---|---|
| OQ3 | Base resolution for `config.lua`? | **960×540, landscape.** Standard Solar2D landscape target. Letterbox scale mode. | Phase 1 |
| OQ4 | Are audio files available? | **No.** Must be sourced before Phase 10. Use free CC0 SFX (e.g. freesound.org). Short OGG files preferred for HTML5 compatibility. Placeholder silence is acceptable to unblock earlier phases. | Phase 10 |
| OQ5 | Sound toggle on title screen in MVP? | **Deferred post-MVP.** Title screen stays minimal. Sound toggle is an REQUIREMENTS.md optional item. | Phase 9 / 10 |
| OQ6 | Fixed seed value? | **`20250101`** — memorable, year-based. Record as `FIXED_SEED = 20250101` in `constants.lua`. | Phase 4 |
| OQ7 | Target `SCROLL_SPEED`? | **200 pixels/second** at 960px wide base (≈ 4.8 s to cross screen). Tune after Phase 3 feel test if needed. Record as `SCROLL_SPEED = 200` in `constants.lua`. | Phase 3 / 4 |
| OQ8 | Launcher icon required for Android APK in MVP? | **Placeholder acceptable.** Use a simple solid-color PNG at required sizes. Real icon is post-MVP. | Phase 12 |
| OQ9 | Public hosting after HTML5 verification? | **Not required for MVP.** itch.io is the natural fit if hosting is wanted later. Add a deployment phase post-MVP if desired. | Phase 11 |
