# TODO.md — CoolCave Implementation

## Phase 1 — Project scaffold, build pipeline, and verified HTML5 output
- [x] Create main.lua with minimal Composer entry point
- [x] Create config.lua with landscape orientation and letterbox scale
- [x] Create build.settings with Android package name and landscape lock
- [x] Create empty scenes/, systems/, util/, assets/ directories with .gitkeep
- [x] Verify project opens and runs in Solar2D simulator (no Lua errors)
- [x] Produce HTML5 build via Solar2D HTML5 build target
- [x] Serve HTML5 output via local HTTP server and verify in Chrome
- [x] Verify HTML5 output in Firefox
- [x] Write DEV_NOTES.md documenting build steps and local test workflow

## Phase 2 — Scene skeleton with Composer and game loop stub
- [x] Create scenes/menu.lua stub with title label and tap-to-start
- [x] Create scenes/game.lua stub with enterFrame listener and placeholder rect
- [x] Create scenes/gameover.lua stub with game-over label and tap-to-restart
- [x] Wire scene navigation in main.lua
- [x] Verify tap-through navigation works in simulator (no Lua errors)
- [x] Verify tap-through navigation works in HTML5 browser build
- [x] Confirm enterFrame listener is cleaned up on scene exit (add debug print)

## Phase 3 — Player movement system with input handling
- [x] Create util/math_utils.lua with clamp() and lerp() functions
- [x] Create constants.lua with RISE_ACC, FALL_ACC, MAX_VY_UP, MAX_VY_DOWN, AVATAR_W, AVATAR_H, PLAYER_X
- [x] Create systems/player.lua with y/vy state, fixed-timestep update, rise/fall acceleration
- [x] Add velocity clamping to player update
- [x] Implement touch/mouse input handler setting isHeld flag in player.lua
- [x] Integrate player into scenes/game.lua enterFrame loop
- [x] Test: avatar rises on hold, falls on release, in simulator
- [x] Test: avatar behavior matches in HTML5 browser build
- [x] Test: velocity clamp works (hold 3 seconds, check max speed not exceeded)
- [x] Manual feel test: confirm floaty, non-twitchy movement
- [x] Confirm fixed timestep is used (document in player.lua comment)

## Phase 4 — Seeded cave generator producing slice data
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

## Phase 5 — Cave feasibility validator (reachability simulation)
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

## Phase 6 — Cave rendering, scrolling, and collision detection
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

## Phase 7 — Trail rendering (chain of small blocks)
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

## Phase 8 — Score tracking and local persistence
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

## Phase 9 — Full game flow integration (title, gameplay, game-over, restart)
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

## Phase 10 — Audio integration with HTML5 compatibility
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

## Phase 11 — HTML5 verification, polish, and browser sign-off
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

## Phase 12 — Android build pipeline and device verification
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

## Phase 13 — Stabilization and final review
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
