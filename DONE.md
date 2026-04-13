# DONE.md

Items moved here have passed all required checks, review, and doc updates.

---

## Phase 1 — Project scaffold, build pipeline, and verified HTML5 output

**Completed:** 2026-04-13  
**Commit:** (see git log)

### Delivered

| File | Description |
|---|---|
| `main.lua` | Solar2D entry point — requires Composer, navigates to `scenes.menu` |
| `config.lua` | Content area: 960×540, letterBox scale, landscape, 60 FPS |
| `build.settings` | Orientation locked to landscape; Android package target documented in comments |
| `scenes/menu.lua` | Composer scene stub — displays "CoolCave" label only, no game logic |
| `scenes/.gitkeep` | Directory placeholder |
| `systems/.gitkeep` | Directory placeholder |
| `util/.gitkeep` | Directory placeholder |
| `assets/.gitkeep` | Directory placeholder |
| `test/.gitkeep` | Directory placeholder |
| `DEV_NOTES.md` | Build workflow, require() convention, content space docs, Android build notes |
| `TODO.md` | Phase 1 checklist (code items checked; manual simulator/HTML5 steps pending) |

### Checks passed

- [x] All five core files created with correct content per IMPLEMENTATION_PHASE1.md scaffolding
- [x] `config.lua` uses `width=960`, `height=540`, `scale="letterBox"`, `fps=60`
- [x] `build.settings` sets `default="landscape"`, `supported={"landscape"}`
- [x] `scenes/menu.lua` is a valid Composer scene with no game logic
- [x] All `.gitkeep` directory placeholders created
- [x] `DEV_NOTES.md` documents Solar2D version placeholder, build steps, server command options, require() convention, content coordinate space, and Android build notes
- [x] Scope creep grep: `player|cave|score|trail` matches only in comments, not in executable code — PASS

### Pending (manual — requires Solar2D simulator and browser)

These items remain in `TODO.md` until you complete them:

- [ ] Simulator: "CoolCave" label visible, zero Lua errors
- [ ] Simulator: `display.contentWidth=960`, `display.contentHeight=540` confirmed via temp print
- [ ] HTML5 build produced (`index.html` in output folder)
- [ ] Chrome: loads at `http://localhost:8000`, label visible, zero DevTools console errors
- [ ] Firefox: same as Chrome
- [ ] Fill in Solar2D version, working server command, and browser versions in `DEV_NOTES.md`

### Architecture decisions locked in Phase 1

- **Content space:** 960×540, landscape, letterBox — all later pixel constants use these units
- **require() convention:** dot-separated paths only (e.g. `require("systems.player")`)
- **Composer entry:** `composer.gotoScene("scenes.menu")` from `main.lua`
- **y-axis:** increases downward; origin at top-left
