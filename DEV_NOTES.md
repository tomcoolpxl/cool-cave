# DEV_NOTES.md

Developer workflow notes for CoolCave. Not shipped in release builds.

## Solar2D version

[Fill in: e.g. 2025.3722 — record the exact build number you are using]

## Opening in simulator

1. Open Solar2D simulator.
2. File → Open → select the project root directory (the folder that contains `main.lua`).
3. Expected: "CoolCave" label centred on a landscape canvas, zero errors in the console panel.

## Verifying content dimensions (Phase 1 check)

Temporarily add this line to `main.lua` after the `require("composer")` line:

```lua
print("content:", display.contentWidth, display.contentHeight)
```

Expected output in simulator console: `content: 960 540`

Remove the line after confirming. Do not commit it.

## Building HTML5

1. In Solar2D simulator: **File → Build → HTML5**.
2. Choose an output directory (e.g. a `dist/` folder next to the project root, or anywhere convenient).
3. Click **Build** and wait for the success message.
4. Inspect the output — `index.html` must be at the root of the output folder, not nested inside a subdirectory named after the project. If it is nested, serve from that subdirectory.

## Serving the HTML5 build locally

**IMPORTANT:** Do not open `index.html` directly from the filesystem (`file://`). WebAssembly loading is blocked by browser CORS policy without an HTTP origin.

From the directory that contains `index.html`, run one of:

```bash
# Option A — Python (use "python" on Windows, "python3" on macOS/Linux)
python -m http.server 8000

# Option B — Node.js (no Python needed)
npx serve .

# Option C — Node.js http-server
npx http-server . -p 8000
```

Then open: `http://localhost:8000`

[Fill in: record which option works on this machine]

## Browser test matrix

| Browser | Version | Result |
|---------|---------|--------|
| Chrome  | [fill]  | [fill] |
| Firefox | [fill]  | [fill] |

Check DevTools console (F12 → Console) in each browser — must show zero errors and zero warnings.

## Android build (Phase 12 — not needed yet)

- **Package name:** `com.coolcave.game` — set in the Solar2D **Build dialog**, not in `build.settings`.
- **Min SDK:** 21 (Android 5.0 Lollipop). Set in the Build dialog.
- **Debug keystore:** generate before Phase 12 with:
  ```bash
  keytool -genkey -v -keystore debug.keystore -alias androiddebugkey \
    -keyalg RSA -keysize 2048 -validity 10000
  ```
- **Device/emulator:** [fill in what you plan to use — physical device or AVD]
- Confirm device is reachable: `adb devices` must list it.

## `require()` path convention

Solar2D uses **dot-separated** module paths, not slash-separated:

```lua
require("systems.player")    -- correct — loads systems/player.lua
require("util.random")       -- correct — loads util/random.lua
require("systems/player")    -- WRONG — will throw "module not found"
```

This is a common trap. All `require()` calls in this project must use dots.

## Content coordinate space

| Property | Value |
|---|---|
| Width | 960 content units |
| Height | 540 content units |
| Orientation | Landscape |
| Scale mode | letterBox (aspect-ratio preserved; black bars on non-16:9 screens) |
| Origin (0,0) | Top-left corner |
| y direction | Increases downward |
| `display.contentCenterX` | 480 |
| `display.contentCenterY` | 270 |

All gameplay constants (player x position, cave gap, slice width, scroll speed) are expressed in these units. Do not change the base resolution without updating every dependent constant.

## Scene navigation (Composer)

Scenes are referenced by their dot-path module name:

```lua
composer.gotoScene("scenes.menu")      -- loads scenes/menu.lua
composer.gotoScene("scenes.game")      -- loads scenes/game.lua
composer.gotoScene("scenes.gameover")  -- loads scenes/gameover.lua
```

All game objects must be inserted into `self.view` (the Composer scene group) so they are cleaned up automatically when the scene is hidden or destroyed.

## Fixed timestep note (Phase 3+)

The player physics update uses a **fixed timestep of 1/60 seconds**, not `event.time` delta. This ensures deterministic behaviour across platforms (HTML5 vs native) regardless of actual frame timing. Do not change this without updating the cave validator, which uses the same timestep assumption.
