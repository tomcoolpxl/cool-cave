# Project Rules

This repository builds CoolCave

Authoritative project files:

- `REQUIREMENTS.md`
- `IMPLEMENTATION_PLAN.md`
- `TODO.md`
- `DONE.md`

Project rules:

- Keep one `TODO.md` item small enough for one review cycle.
- Refresh `TODO.md` from the current phase in `IMPLEMENTATION_PLAN.md`.
- Update `TODO.md` before starting a new implementation chunk.
- Update `TODO.md` and `DONE.md` after implementation.
- Move an item to `DONE.md` only after the required checks, review, and doc updates are complete.
- `DONE.md` holds only verified work.
- Update `REQUIREMENTS.md` when scope or acceptance criteria change.
- Update `IMPLEMENTATION_PLAN.md` when the order or grouping of work changes.
- For narrow tasks, pass the exact authoritative files in the prompt instead of retyping context.
- Ask before making a large refactor, changing the directory structure, or removing tests.
- Before moving work to `DONE.md`, review the diff, run the required checks, and update docs if the change affected scope or structure.

# Testing & Launching

## Solar2D Simulator (Local Desktop)
To run the game in the simulator for rapid development:
- **Command:** `& "C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe" -project "C:\Users\thraa\github\cool-cave\main.lua"`
- **Verification:** Check the simulator console for Lua errors. Ensure the window shows the expected UI.

## HTML5 Build & Test
To verify the game in a browser (essential for cross-platform parity):
1. **Build:** `& "C:\Program Files (x86)\Corona Labs\Corona\Corona Simulator.exe" -build "C:\Users\thraa\github\cool-cave\main.lua" -platform html5 -output "C:\Users\thraa\github\cool-cave\dist"`
2. **Serve:** Run `python -m http.server 8000` from the `dist` directory.
3. **Test:** Open `http://localhost:8000` in Chrome and Firefox.
4. **Verification:** Check DevTools Console (F12) for JS errors.

## Code Quality
- **Grep Check:** Always grep for "TODO", "FIXME", or specific logic keywords (e.g., "player", "cave") to ensure no unfinished work is committed.
- **Cleanup:** Ensure `enterFrame` listeners are removed on scene exit to prevent memory leaks.

# Coding

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
