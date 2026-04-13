# IMPLEMENTATION_PHASE1.md — Project Scaffold, Build Pipeline, and Verified HTML5 Output

**Phase:** 1 of 13  
**Status:** Not started  
**Prerequisite phases:** None  
**Blocks:** Phase 2 (scene skeleton)

---

## 0. Context and Goal

Phase 1 produces a buildable, runnable Solar2D project with zero game logic. Its only job is:

1. Establish the canonical directory layout that every later phase will extend.
2. Lock in the Solar2D `config.lua` constants that all rendering will depend on (base resolution, scale mode, orientation).
3. Prove the HTML5 build pipeline is operational on this machine.
4. Leave a `DEV_NOTES.md` that any contributor can follow to reproduce a browser test run.

**Exit gate:** Simulator shows a placeholder label with zero Lua errors. HTML5 build loads at `localhost:8000` with zero JS console errors in Chrome and Firefox. `DEV_NOTES.md` documents the exact workflow.

---

## 1. Architectural Design

### 1.1 Display coordinate system (canonical for all phases)

Solar2D places the origin `(0, 0)` at the **top-left** corner of the content area. `y` increases **downward**. All later systems (player physics, cave slice bounds, collision) must use this convention consistently.

| Constant | Value | Reason |
|---|---|---|
| `content.width` | `960` | Standard landscape width; gives a wide, readable cave passage |
| `content.height` | `540` | 16:9 landscape height; fits most phone and browser aspect ratios |
| `content.scale` | `"letterBox"` | Preserves aspect ratio; adds neutral bars on non-16:9 screens rather than stretching |
| `content.fps` | `60` | Target frame rate; Solar2D enforces this as a cap |

**Why `letterBox` and not `zoomEven` or `adaptive`?**  
`zoomEven` crops content — parts of the cave would be invisible on narrow screens. `adaptive` changes the effective content area size, which would require all gameplay constants (PLAYER_X, MIN_GAP, SCROLL_SPEED) to be expressed in percentages, not absolute pixels. `letterBox` is the simplest model for a fixed-layout game where all geometry is authored in pixel coordinates.

**Why 960×540 and not 1280×720 or 480×270?**  
960×540 keeps pixel math small (easier to reason about constants), avoids sub-pixel artefacts common at 480×270, and renders without visible upscale blur at 1920×1080 targets. All later constants (AVATAR_W, MIN_GAP, SLICE_WIDTH) will be expressed in these units.

### 1.2 Display group hierarchy (established in Phase 1, extended later)

```
stage (Solar2D root)
└── display.getCurrentStage()
    └── [scene group managed by Composer]
        └── placeholder label (Phase 1 only)
```

Composer owns one scene group per scene. All game objects are inserted into the scene group so they are automatically removed when a scene is hidden or destroyed. This pattern must be followed from the very first scene created in Phase 2.

Phase 1 does **not** introduce this hierarchy — it only loads Composer and goes to the menu scene stub. The hierarchy is documented here so Phase 2 uses it correctly from the start.

### 1.3 Module loading pattern

Solar2D uses `require()` with dot-separated paths relative to the project root. Directory separators are **dots**, not slashes.

```lua
-- Correct
local composer = require("composer")
local C = require("constants")        -- constants.lua at root

-- Correct for subdirectory modules (Phase 2+)
local player = require("systems.player")
local rng    = require("util.random")

-- Wrong — Solar2D does not use slashes in require paths
local player = require("systems/player")  -- will error
```

This is a common trap. Document it in `DEV_NOTES.md`.

### 1.4 Scene entry point pattern (for reference in Phase 2)

```lua
-- main.lua pattern
local composer = require("composer")
composer.gotoScene("scenes.menu")     -- maps to scenes/menu.lua
```

`composer.gotoScene` takes the module path as a string using dot notation.

---

## 2. File-Level Strategy

### Files to create in Phase 1

| File | Responsibility | Notes |
|---|---|---|
| `main.lua` | Solar2D entry point. Requires Composer, goes to `scenes.menu` stub. No game logic. | Keeps responsibility to < 10 lines. |
| `config.lua` | Defines content area (960×540), scale mode (`letterBox`), FPS (60), orientation (landscape). | Read by Solar2D before `main.lua` runs — format is fixed. |
| `build.settings` | Locks orientation to landscape. Sets Android package name and `minSdkVersion`. | Controls Android manifest and iOS plist generation. |
| `scenes/menu.lua` | **Phase 1 stub only.** Displays a text label. No tap handler yet. | Needed so Composer has a valid scene to navigate to. |
| `DEV_NOTES.md` | Documents: how to open in Solar2D simulator, how to build HTML5, how to serve locally, how to test in Chrome and Firefox. | Not shipped in release. Checked into repo for contributor onboarding. |

### Directories to create (with `.gitkeep` to allow empty-dir tracking)

| Directory | Purpose |
|---|---|
| `scenes/` | Composer scene files |
| `systems/` | Gameplay subsystems (player, cave, collision, etc.) |
| `util/` | Pure-logic utility modules (RNG, math helpers) |
| `assets/` | Art and audio assets (placeholder for now) |
| `test/` | Debug harness scripts (not shipped; `.gitignore` or guard with `if false then`) |

### Files NOT to create in Phase 1

- `constants.lua` — added in Phase 3 when first movement constants are needed
- Any `systems/*.lua` — Phase 3+
- Any `util/*.lua` — Phase 3+
- Any audio or image assets — Phase 9+

---

## 3. Atomic Execution Steps

Each TODO checkbox from `IMPLEMENTATION_PLAN.md` Phase 1 gets a Plan-Act-Validate cycle.

---

### Step 1 — Create `main.lua` with minimal Composer entry point

**Plan**

`main.lua` is the Solar2D entry point. It must require Composer and navigate to the menu scene. Nothing else. The scene stub must exist before this runs.

**Act**

```lua
-- main.lua
-- Entry point. Loads Composer and navigates to the title screen.
-- No game logic belongs here.

local composer = require("composer")
composer.gotoScene("scenes.menu")
```

**Validate**

- Open project in Solar2D simulator. Simulator console must show no Lua errors.
- If `scenes/menu.lua` does not exist yet, the simulator will error on `gotoScene`. Create the stub first (Step 5).
- Confirm that removing the `composer.gotoScene` line and replacing it with `print("ok")` shows no error — isolates Composer from the menu stub if debugging.

---

### Step 2 — Create `config.lua` with landscape orientation and letterBox scale

**Plan**

`config.lua` is read by Solar2D before `main.lua`. It must define the content area. The format is a fixed Solar2D API — the `application.content` table. Deviation from this format silently falls back to defaults, which will cause incorrect rendering in later phases.

**Act**

```lua
-- config.lua
-- Defines the content coordinate space for all rendering.
-- 960x540 landscape, letterBox scale, 60 FPS.
-- All gameplay constants (gap sizes, speeds, positions) are expressed in these units.

application = {
    content = {
        width  = 960,
        height = 540,
        scale  = "letterBox",
        fps    = 60,

        imageSuffix = {
            -- Add suffixes here if high-DPI assets are introduced later.
            -- ["@2x"] = 2,
        },
    },
}
```

**Validate**

- In Solar2D simulator: `display.contentWidth` must equal `960` and `display.contentHeight` must equal `540`. Add a temporary `print(display.contentWidth, display.contentHeight)` to `main.lua` to confirm, then remove it.
- Resize the simulator window — content must letterbox (black bars appear), not stretch.
- In HTML5 build: resize the browser window — same letterbox behavior expected.

**Edge case:** If `config.lua` is missing or malformed, Solar2D falls back to default content size (320×480 portrait). This will break all slice position math in later phases. Catch this early.

---

### Step 3 — Create `build.settings` with Android package name and landscape lock

**Plan**

`build.settings` is a Lua file read only during the build process, not at runtime. It configures:
- Orientation lock (landscape for both Android and iOS/HTML5)
- Android package identifier
- Android minimum SDK version (21 = Android 5.0 Lollipop, covers ~99% of active devices)

**Act**

```lua
-- build.settings
-- Build-time configuration for Android and HTML5 targets.
-- Not loaded at runtime — changes here require a rebuild to take effect.

settings = {
    orientation = {
        default   = "landscape",
        supported = { "landscape" },
    },

    android = {
        applicationChildElements = {
            -- Permissions and manifest entries added here as needed.
        },
    },

    plugins = {
        -- Third-party plugins declared here when needed.
    },
}
```

**Notes on the Android package name:**  
The package name (e.g. `com.coolcave.game`) is set in the Solar2D **Build dialog**, not in `build.settings`. Document this in `DEV_NOTES.md` so it is not forgotten at Android build time (Phase 12).

**Validate**

- Build HTML5 from Solar2D — build must complete without warnings about orientation or settings.
- In HTML5 output, the canvas should be landscape (wider than tall).
- Confirm `build.settings` is syntactically valid Lua: `luac -p build.settings` (if `luac` is available) or just confirm simulator opens without errors after the file is added.

---

### Step 4 — Create empty directory structure with `.gitkeep` files

**Plan**

Git does not track empty directories. Four directories must exist for later phases to `require()` modules from them. Add a `.gitkeep` placeholder file to each.

**Act**

Create the following files (empty content):

```
scenes/.gitkeep
systems/.gitkeep
util/.gitkeep
assets/.gitkeep
test/.gitkeep
```

**Validate**

- `git status` must show the `.gitkeep` files as new untracked files (or staged if added).
- `git ls-files scenes/` must return `scenes/.gitkeep`.
- A `require("systems.player")` call in a future phase must not error with "no such directory" — the directory existing (even empty) is sufficient for Solar2D's module loader.

---

### Step 5 — Create `scenes/menu.lua` stub (Phase 1 version)

**Plan**

This is the minimum Composer scene needed so `main.lua` can navigate to it without error. It must:
- Follow the Composer scene boilerplate exactly.
- Show a single text label ("CoolCave" or "Loading...").
- Register and clean up the `scene:show` listener.
- Add **no** tap handler, no game logic, no imports beyond `composer`.

This stub will be replaced by the real menu in Phase 9. Do not add anything beyond what is listed.

**Act**

```lua
-- scenes/menu.lua
-- Phase 1 stub. Displays a placeholder label only.
-- Full menu implementation is in Phase 9.

local composer = require("composer")
local scene    = composer.newScene()

function scene:create(event)
    local group = self.view

    local label = display.newText({
        parent   = group,
        text     = "CoolCave",
        x        = display.contentCenterX,
        y        = display.contentCenterY,
        fontSize = 48,
    })
    label:setFillColor(1, 1, 1)
end

scene:addEventListener("create", scene)

return scene
```

**Validate**

- Simulator shows "CoolCave" label centered on screen.
- Simulator console: zero Lua errors.
- No tap handler fires on click (this is correct for Phase 1 — Phase 2 adds navigation).

---

### Step 6 — Verify project opens and runs in Solar2D simulator (no Lua errors)

**Plan**

This is a manual verification step, not a code step. Open the project root directory in Solar2D simulator and confirm clean output.

**Act (manual)**

1. Open Solar2D simulator.
2. File → Open → select the `cool-cave/` directory.
3. Observe the simulator window and the console output panel.

**Validate**

- Simulator window displays "CoolCave" label.
- Console panel shows zero lines starting with `ERROR` or `WARNING`.
- Frame rate indicator (if visible) shows ~60 FPS.
- Close and reopen the project — same result (rules out one-time initialization issues).

---

### Step 7 — Produce HTML5 build via Solar2D HTML5 build target

**Plan**

Solar2D's HTML5 build converts the Lua project to JavaScript/WebAssembly and produces a self-contained output folder. This step confirms the build pipeline is operational.

**Act (manual)**

1. In Solar2D simulator: File → Build → HTML5.
2. Set output directory (e.g. `cool-cave-html5/` next to the project, or a `dist/html5/` subfolder).
3. Click Build. Wait for completion.
4. Locate the output folder — it must contain `index.html`, `*.js`, and `*.wasm` (or `*.js.mem` depending on Solar2D version).

**Document the exact output path in `DEV_NOTES.md`.**

**Validate**

- Build dialog reports success (no error dialog).
- Output folder exists and contains `index.html`.
- `index.html` is not empty.

---

### Step 8 — Serve HTML5 output via local HTTP server and verify in Chrome

**Plan**

HTML5 builds must be served over HTTP — opening `index.html` directly from the filesystem (`file://`) will fail due to browser CORS restrictions on WebAssembly and module loading. A local HTTP server is required.

**Act (manual)**

From the HTML5 output directory:

```bash
# Option A — Python (Windows default install: python, not python3)
python -m http.server 8000

# Option B — Node.js (no Python needed)
npx serve .

# Option C — Node.js http-server
npx http-server . -p 8000
```

Open `http://localhost:8000` in Chrome.

**Document the working command in `DEV_NOTES.md`** — include which option was confirmed working on this machine.

**Validate**

- Page loads without a "blocked by CORS" error.
- "CoolCave" label appears on canvas.
- Chrome DevTools console (F12 → Console): zero errors, zero warnings.
- Canvas is landscape orientation (wider than tall).

---

### Step 9 — Verify HTML5 output in Firefox

**Plan**

Firefox handles WebAssembly and CORS slightly differently from Chrome. A second browser check catches browser-specific issues early before they compound with game logic.

**Act (manual)**

With the local HTTP server still running:
1. Open Firefox.
2. Navigate to `http://localhost:8000`.

**Validate**

- Page loads without error.
- "CoolCave" label visible.
- Firefox DevTools console (F12): zero errors.
- Canvas is landscape.

---

### Step 10 — Write `DEV_NOTES.md` documenting build steps and local test workflow

**Plan**

`DEV_NOTES.md` is a living document that captures machine-specific workflow details that are not expressible in source code. It must be accurate enough that a fresh contributor can reproduce the test environment without asking questions.

**Act**

Create `DEV_NOTES.md` at the project root with at minimum:

```markdown
# DEV_NOTES.md

## Solar2D version

[Record the exact Solar2D build number used, e.g. 2025.3722]

## Opening the project

1. Open Solar2D simulator.
2. File → Open → select the `cool-cave/` directory.
3. The simulator should show the "CoolCave" label.

## Building HTML5

1. In Solar2D: File → Build → HTML5.
2. Set output directory to: [record the exact path you used]
3. Click Build. Wait for the success message.

## Serving the HTML5 build locally

From the HTML5 output directory, run:

```bash
[paste the exact command that worked on this machine]
```

Then open `http://localhost:8000` in your browser.

## Confirmed working browsers

- Chrome [version]: OK
- Firefox [version]: OK

## Android build (Phase 12)

Android package name: `com.coolcave.game`  
Set in Solar2D Build dialog (not in build.settings).  
Debug keystore: generate with `keytool -genkey ...` before Phase 12.  
Target device/emulator: [record what you plan to use]

## require() path convention

Solar2D uses dot-separated module paths, not slash-separated:
- Correct:   `require("systems.player")`
- Incorrect: `require("systems/player")`

## Content coordinate space

960 × 540 pixels, landscape, letterBox scale.
Origin (0,0) is top-left. y increases downward.
```

**Validate**

- File exists at `cool-cave/DEV_NOTES.md`.
- A second person (or future self) could follow the steps without external help.
- The exact local server command is recorded (not just "use a local server").

---

## 4. Edge Case & Boundary Audit

### 4.1 `config.lua` silent fallback

**Risk:** If `config.lua` is syntactically valid Lua but uses a wrong key name (e.g. `contents` instead of `content`), Solar2D silently uses its default content size (320×480 portrait). This will not error — it will just produce wrong rendering.

**Mitigation:** After loading, print `display.contentWidth` and `display.contentHeight` in `main.lua` temporarily and verify they equal `960` and `540`.

### 4.2 Orientation not locked in HTML5

**Risk:** `build.settings` orientation lock affects native builds but may not enforce orientation in the browser canvas. The HTML5 canvas may be portrait if the browser window is narrow.

**Mitigation:** The letterBox scale mode will keep the content landscape even if the canvas is resized — black bars will appear. Document this in `DEV_NOTES.md`. Full orientation lock in HTML5 requires JavaScript changes to the Solar2D HTML5 template (out of scope for Phase 1).

### 4.3 `file://` vs `http://` for HTML5

**Risk:** Developer opens `index.html` directly from the filesystem. WebAssembly fails to load with a CORS or "cross-origin" error. This looks like a build failure when it is actually a serving issue.

**Mitigation:** `DEV_NOTES.md` must explicitly warn against opening `index.html` directly and specify that `http://localhost:8000` is required.

### 4.4 Python version on Windows

**Risk:** On Windows, the Python executable may be `python` (not `python3`). Running `python3 -m http.server 8000` fails with "command not found". This is an assumption documented in `IMPLEMENTATION_PLAN.md` as A3.

**Mitigation:** Try `python -m http.server 8000` first. If both fail, use `npx serve .` (requires Node.js). Record the working command in `DEV_NOTES.md`.

### 4.5 Composer `gotoScene` before scene file exists

**Risk:** If `main.lua` is created before `scenes/menu.lua`, running the simulator will throw:
```
ERROR: Runtime error: module 'scenes.menu' not found
```

**Mitigation:** Create `scenes/menu.lua` stub (Step 5) before running the simulator (Step 6). The order in the Execution Steps above reflects this dependency.

### 4.6 `.gitkeep` files in `assets/` and `test/`

**Risk:** If `.gitkeep` files are accidentally required by Solar2D's module loader (e.g., a typo like `require("assets")`), Solar2D will try to parse them as Lua and error.

**Mitigation:** Solar2D's `require()` only loads files when explicitly called. An empty `.gitkeep` will not be loaded automatically. No action needed, but note this in `DEV_NOTES.md` as a reminder not to name modules after their parent directories.

### 4.7 Solar2D HTML5 build produces a nested output folder

**Risk:** Solar2D HTML5 build may produce `output_dir/CoolCave/index.html` (nested inside a project-named subdirectory) rather than `output_dir/index.html`. Serving from `output_dir` and navigating to `localhost:8000` returns a directory listing, not the game.

**Mitigation:** After the build, inspect the output directory structure before running the server. Serve from the directory that directly contains `index.html`, not its parent.

### 4.8 Solar2D simulator FPS cap

**Risk:** The Solar2D simulator on some machines caps at 30 FPS regardless of `fps = 60` in `config.lua`. This is a simulator limitation, not a game bug. The HTML5 and device builds are not affected.

**Mitigation:** Note this in `DEV_NOTES.md`. Do not tune gameplay constants to compensate for simulator FPS — always use the fixed timestep of `1/60` seconds (documented in Phase 3).

---

## 5. Verification Protocol

### 5.1 Simulator checks (manual, in order)

| # | Check | Expected result | Fail action |
|---|---|---|---|
| S1 | Open project in Solar2D simulator | Simulator window opens, "CoolCave" label visible | Check `scenes/menu.lua` exists; check console for errors |
| S2 | Check simulator console | Zero `ERROR` lines, zero `WARNING` lines | Read error message; fix syntax |
| S3 | Print `display.contentWidth` and `display.contentHeight` | Outputs `960` and `540` | Check `config.lua` key spelling (`content`, not `contents`) |
| S4 | Close and reopen project | Same result | Rules out one-time init issue |

### 5.2 HTML5 build checks (manual, in order)

| # | Check | Expected result | Fail action |
|---|---|---|---|
| H1 | Build HTML5 via Solar2D | Build dialog reports success | Check Solar2D version; check console for build errors |
| H2 | Inspect output directory | `index.html` exists at root of output | Serve from nested subdirectory if needed |
| H3 | Start local HTTP server | Server starts and prints listening address | Try alternative server command (see 4.4) |
| H4 | Open `http://localhost:8000` in Chrome | "CoolCave" label visible, canvas is landscape | Check DevTools console for WASM errors |
| H5 | Check Chrome DevTools Console | Zero errors, zero warnings | Note any CORS or WASM errors; document in `DEV_NOTES.md` |
| H6 | Open `http://localhost:8000` in Firefox | Same as Chrome | Note any Firefox-specific differences |
| H7 | Check Firefox DevTools Console | Zero errors | Same as H5 |
| H8 | Resize browser window | Black bars appear (letterBox), label stays centered | If content stretches, verify `scale = "letterBox"` in `config.lua` |

### 5.3 File completeness check

Run before marking Phase 1 done:

```bash
# All of these must exist
ls main.lua
ls config.lua
ls build.settings
ls scenes/menu.lua
ls DEV_NOTES.md
ls scenes/.gitkeep
ls systems/.gitkeep
ls util/.gitkeep
ls assets/.gitkeep
```

### 5.4 Scope creep check

Grep the new files for anything that should not exist in Phase 1:

```bash
# Must return zero matches
grep -r "player" main.lua config.lua build.settings scenes/menu.lua
grep -r "cave"   main.lua config.lua build.settings scenes/menu.lua
grep -r "score"  main.lua config.lua build.settings scenes/menu.lua
grep -r "trail"  main.lua config.lua build.settings scenes/menu.lua
```

---

## 6. Code Scaffolding

The following are the complete, final code templates for Phase 1 files. These are not pseudocode — they are the actual files to write verbatim. Later phases will edit them.

### `main.lua`

```lua
-- main.lua
-- CoolCave entry point.
-- Initialises Composer and navigates to the title scene.

local composer = require("composer")

composer.gotoScene("scenes.menu")
```

### `config.lua`

```lua
-- config.lua
-- Defines the content coordinate space used by all rendering.
-- 960x540 landscape, letterBox scaling, 60 FPS.
--
-- All gameplay geometry (player position, cave gap, slice width) is
-- expressed in these content units. Do not change this after Phase 1
-- without updating every constant that depends on it.

application = {
    content = {
        width  = 960,
        height = 540,
        scale  = "letterBox",
        fps    = 60,
    },
}
```

### `build.settings`

```lua
-- build.settings
-- Build-time configuration only. Not loaded at runtime.
-- Changes here require a rebuild to take effect.

settings = {
    orientation = {
        default   = "landscape",
        supported = { "landscape" },
    },

    android = {
        -- Package name is set in the Solar2D Build dialog, not here.
        -- Target: com.coolcave.game
        -- minSdkVersion is set in the Build dialog (target API 21+).
    },

    plugins = {
        -- No third-party plugins in Phase 1.
    },
}
```

### `scenes/menu.lua` (Phase 1 stub)

```lua
-- scenes/menu.lua
-- Phase 1 stub: displays a placeholder label only.
-- Full title screen (tap handler, best score, start prompt) is implemented in Phase 9.

local composer = require("composer")
local scene    = composer.newScene()

function scene:create(event)
    local group = self.view

    local label = display.newText({
        parent   = group,
        text     = "CoolCave",
        x        = display.contentCenterX,
        y        = display.contentCenterY,
        fontSize = 48,
    })
    label:setFillColor(1, 1, 1)
end

scene:addEventListener("create", scene)

return scene
```

### `DEV_NOTES.md` (starter template — fill in machine-specific values)

```markdown
# DEV_NOTES.md

Developer workflow notes for CoolCave. Not shipped in release builds.

## Solar2D version

[Fill in: e.g. 2025.3722]

## Opening in simulator

1. Open Solar2D simulator.
2. File → Open → select the project root directory (contains main.lua).
3. Expected: "CoolCave" label centred on a landscape canvas.

## Building HTML5

1. In Solar2D: File → Build → HTML5.
2. Output directory: [fill in the path you chose]
3. Click Build and wait for the success message.
4. The output directory contains index.html at its root. Serve from there.

## Serving the HTML5 build locally

IMPORTANT: Do not open index.html directly from the filesystem.
WebAssembly requires an HTTP origin. Use one of:

Option A (Python — use "python" on Windows, "python3" on macOS/Linux):
  python -m http.server 8000

Option B (Node.js, no Python needed):
  npx serve .

[Fill in: record which option works on this machine]

Then open: http://localhost:8000

## Browser test matrix

| Browser | Version | Result |
|---------|---------|--------|
| Chrome  | [fill]  | OK     |
| Firefox | [fill]  | OK     |

## Android build (Phase 12 — not yet needed)

- Package name: com.coolcave.game (set in Solar2D Build dialog)
- Min SDK: 21 (Android 5.0)
- Debug keystore: generate before Phase 12 with:
    keytool -genkey -v -keystore debug.keystore -alias androiddebugkey \
      -keyalg RSA -keysize 2048 -validity 10000
- Device/emulator: [fill in]

## Module require() convention

Solar2D uses dot-separated paths:
  require("systems.player")    -- correct, loads systems/player.lua
  require("systems/player")    -- wrong, will error

## Content coordinate space

960 × 540, landscape, letterBox scale.
Origin (0,0) = top-left. y increases downward.
display.contentCenterX = 480, display.contentCenterY = 270.
```

---

## 7. TODO.md Entries for Phase 1

Paste these into `TODO.md` at the start of Phase 1 implementation:

```markdown
## Phase 1

- [ ] Create main.lua with minimal Composer entry point
- [ ] Create config.lua with landscape orientation and letterBox scale
- [ ] Create build.settings with Android package name and landscape lock
- [ ] Create scenes/menu.lua stub (placeholder label only)
- [ ] Create empty scenes/, systems/, util/, assets/, test/ directories with .gitkeep
- [ ] Verify project opens and runs in Solar2D simulator (no Lua errors)
- [ ] Print display.contentWidth/Height in simulator to confirm 960x540
- [ ] Produce HTML5 build via Solar2D HTML5 build target
- [ ] Serve HTML5 output via local HTTP server and verify in Chrome (no JS console errors)
- [ ] Verify HTML5 output in Firefox (no JS console errors)
- [ ] Write DEV_NOTES.md documenting Solar2D version, build steps, and local server command
- [ ] Scope creep check: grep new files for player/cave/score/trail (must return 0)
```

---

## 8. Exit Criteria Checklist (must pass before moving to DONE.md)

- [ ] `main.lua` exists, requires Composer, navigates to `scenes.menu`. Less than 10 lines.
- [ ] `config.lua` exists with `width=960`, `height=540`, `scale="letterBox"`, `fps=60`.
- [ ] `build.settings` exists with `default="landscape"`, `supported={"landscape"}`.
- [ ] `scenes/menu.lua` stub exists, shows "CoolCave" label, no game logic.
- [ ] `scenes/.gitkeep`, `systems/.gitkeep`, `util/.gitkeep`, `assets/.gitkeep` exist.
- [ ] Solar2D simulator: "CoolCave" label visible, zero Lua errors, `display.contentWidth=960` confirmed.
- [ ] HTML5 build produced (output folder with `index.html` exists).
- [ ] Chrome: page loads at `http://localhost:8000`, label visible, zero DevTools console errors.
- [ ] Firefox: page loads at `http://localhost:8000`, label visible, zero DevTools console errors.
- [ ] `DEV_NOTES.md` exists, contains: Solar2D version, build steps, exact local server command, browser matrix, Android package name, require() convention, content space dimensions.
- [ ] Scope creep grep returns zero matches.
- [ ] All TODO items for this phase are marked complete and moved to `DONE.md`.

---

*Blueprint complete. Do not begin implementation until this document has been reviewed.*
