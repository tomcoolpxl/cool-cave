# IMPLEMENTATION_PHASE2.md — Composer Scene Skeleton and Game Loop Stub

**Phase:** 2 of 13  
**Status:** Not started  
**Prerequisite phases:** Phase 1 (scaffold)  
**Blocks:** Phase 3 (player movement)

---

## 0. Context and Goal

Phase 2 establishes the high-level game flow using Solar2D's **Composer** library. It creates three navigational stubs: **Menu**, **Game**, and **Gameover**. Its goal is to prove that state transitions are clean, memory is managed correctly (listeners are removed), and a 60 FPS `enterFrame` heartbeat is operational in the gameplay scene.

**Exit gate:** Full navigation cycle (Menu → Game → Gameover → Menu) works via tap/click without Lua errors. `enterFrame` logging confirms the loop starts and stops correctly on scene entry/exit.

---

## 1. Architectural Design

### 1.1 Composer Lifecycle and Scene Management

Solar2D Composer scenes follow a specific lifecycle. Phase 2 must strictly adhere to this to prevent memory leaks and "zombie" listeners.

| Event | Responsibility | Phase 2 Action |
|---|---|---|
| `scene:create` | Initial UI layout. Objects added to `self.view`. | Create labels, rects, and tap listeners. |
| `scene:show` | Scene becomes active. Start timers/loops. | Add `"enterFrame"` listener (Game scene only). |
| `scene:hide` | Scene becomes inactive. Stop timers/loops. | Remove `"enterFrame"` listener. |
| `scene:destroy` | Cleanup before memory release. | Remove UI and any persistent data. |

### 1.2 Display Group Hierarchy

Every scene object MUST be inserted into `self.view` (the scene's display group). Composer automatically manages the visibility and removal of this group during transitions.

```
stage
└── composer group
    └── [active scene group]
        ├── background (rect)
        ├── label (text)
        └── [tap area] (invisible rect or group)
```

### 1.3 Event Propagation and Cleanup

To ensure a "surgical" implementation, Phase 2 will use anonymous functions or bound methods for tap listeners, but **must** use a named function for the `enterFrame` listener to ensure successful removal.

---

## 2. File-Level Strategy

### Files to Modify in Phase 2

| File | Responsibility | Change |
|---|---|---|
| `main.lua` | Entry point | No change needed if already navigating to `scenes.menu`. Ensure `composer.gotoScene` is correctly called. |
| `scenes/menu.lua` | Title screen | Replace Phase 1 placeholder with a tap listener that navigates to `scenes.game`. |

### Files to Create in Phase 2

| File | Responsibility | Notes |
|---|---|---|
| `scenes/game.lua` | Gameplay scene | Implements `enterFrame` loop and a placeholder "avatar" rect. Tap triggers `scenes.gameover`. |
| `scenes/gameover.lua` | Termination screen | Displays score stub. Tap triggers `scenes.menu`. |

---

## 3. Atomic Execution Steps

Each TODO checkbox from `TODO.md` Phase 2.

---

### Step 1 — Update `scenes/menu.lua` with tap-to-start

**Plan**

Update the existing `menu.lua` stub. Add a tap listener to the entire screen or a specific button to trigger `composer.gotoScene("scenes.game")`.

**Act**

```lua
-- scenes/menu.lua (Update)
-- Add tap handler to transition to 'game' scene.
-- Use scene:create for UI and scene:show for listener attachment if needed.

local function onStartTap(event)
    composer.gotoScene("scenes.game", { effect = "crossFade", time = 400 })
    return true
end

-- Inside scene:create:
-- Add a background rect to capture taps across the whole screen.
local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
bg.isVisible = false -- Invisible but still captures taps
bg.isHitTestable = true 
bg:addEventListener("tap", onStartTap)
```

**Validate**

- Simulator shows "CoolCave". Clicking anywhere should (eventually) attempt to load `scenes/game`.

---

### Step 2 — Create `scenes/game.lua` with enterFrame loop

**Plan**

Create the gameplay scene stub. It must start a `Runtime` listener on `show` and stop it on `hide`. It should also show a placeholder rectangle (the avatar).

**Act**

```lua
-- scenes/game.lua
local composer = require("composer")
local scene = composer.newScene()

local function onFrame(event)
    -- This represents the 60 FPS heart of the game.
    print("Game Loop Active: " .. event.frame)
end

function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("enterFrame", onFrame)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", onFrame)
    end
end
```

**Validate**

- Simulator console prints "Game Loop Active" 60 times per second when in the game scene.
- Print stops immediately when navigating away.

---

### Step 3 — Create `scenes/gameover.lua` stub

**Plan**

Create the game-over scene. Simple text + tap handler returning to menu.

**Act**

```lua
-- scenes/gameover.lua
-- "Game Over" label + tap to return to menu.
local function onRestartTap(event)
    composer.gotoScene("scenes.menu", { effect = "fade", time = 400 })
    return true
end
```

**Validate**

- Clicking screen in `gameover` returns to `menu`.

---

### Step 4 — Verify cleanup and transitions

**Plan**

Manual walkthrough of the flow. Observe the console for error-free execution and verify the `enterFrame` print behavior.

**Act (manual)**

1. Start app (Menu).
2. Tap (Go to Game). Verify loop prints start.
3. Tap Game (Go to Gameover). Verify loop prints stop.
4. Tap Gameover (Go to Menu).
5. Repeat 3 times.

**Validate**

- No "module not found" errors.
- No "Runtime error: table expected, got nil" (common in listener removal).
- `enterFrame` is never running in Menu or Gameover.

---

## 4. Edge Case & Boundary Audit

### 4.1 Event Listener Accumulation

**Risk:** If `Runtime:removeEventListener` is not called in `scene:hide`, multiple `onFrame` listeners will run concurrently when the user returns to the game scene. This will cause exponential performance degradation.

**Mitigation:** Verify via console logs. Each frame should produce exactly ONE print statement.

### 4.2 Rapid Tapping

**Risk:** User taps twice quickly during a transition. Solar2D may try to load the scene twice or error if `gotoScene` is called while another transition is in progress.

**Mitigation:** Composer handles this generally, but in Phase 9 we might add a `isTransitioning` flag. For Phase 2, verify no crash occurs.

### 4.3 Scene Object Visibility

**Risk:** UI objects from `menu` stay visible in `game`.

**Mitigation:** Ensure ALL objects are inserted into `scene.view`.

---

## 5. Verification Protocol

### 5.1 Manual Navigation Checklist

| # | Check | Expected Result |
|---|---|---|
| N1 | Menu -> Game transition | Game scene loads, "Game Loop Active" starts in console. |
| N2 | Game -> Gameover transition | Gameover scene loads, "Game Loop Active" stops. |
| N3 | Gameover -> Menu transition | Menu scene loads. |
| N4 | Memory Leak Check | Perform 10 transitions. FPS remains stable at 60. |

### 5.2 Console Verification

- [ ] "Game Loop Active" prints only when Game scene is visible.
- [ ] No `ERROR` or `WARNING` lines in Solar2D console.
- [ ] No JavaScript errors in HTML5 build console.

---

## 6. Code Scaffolding

### `scenes/game.lua` Template

```lua
local composer = require("composer")
local scene = composer.newScene()

local function onFrame(event)
    -- STUB: Future home of player:update() and cave:scroll()
    -- print("Game Loop Active")
end

local function onCollisionSim(event)
    composer.gotoScene("scenes.gameover", { effect = "fade", time = 400 })
    return true
end

function scene:create(event)
    local group = self.view
    local avatar = display.newRect(group, 100, display.contentCenterY, 40, 40)
    avatar:setFillColor(0, 1, 0)
    
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    bg.isVisible = false
    bg.isHitTestable = true
    bg:addEventListener("tap", onCollisionSim)
end

function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("enterFrame", onFrame)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", onFrame)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
```

---

## 7. TODO.md Updates (Refined)

```markdown
## Phase 2

- [ ] Create scenes/menu.lua stub with tap-to-start navigation
- [ ] Create scenes/game.lua stub with enterFrame heartbeat and transition to gameover
- [ ] Create scenes/gameover.lua stub with tap-to-restart navigation
- [ ] Verify transition cycle (Menu -> Game -> Gameover -> Menu) in simulator
- [ ] Verify enterFrame cleanup via console logging (no zombie loops)
- [ ] Verify full navigation cycle in HTML5 build
- [ ] Scope check: no movement logic or physics bodies added
```

---

*Blueprint complete. Phase 2 unblocked.*
