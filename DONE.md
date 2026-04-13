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

Verified on: Monday, April 13, 2026
OS: win32
Solar2D Simulator: C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe
Target: HTML5
Result: Success. Title "CoolCave" rendered centrally. Resolution 960x540 confirmed.
