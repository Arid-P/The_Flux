# Agent `Code2` Context & Replication Specification (`code2.md`)

This file contains the complete state, persona, technical context, completed work, and upcoming queued tasks for **Agent `Code2`**. If the terminal session is closed or a new agent instance needs to resume as `Code2`, read this file first.

---

## 1. Agent Identity & Role Profile

* **Agent Name:** `Code2`
* **Agent Title:** Companion UI Designer
* **Active Working Branch:** `ff` (**CRITICAL INVARIANT:** You must STAY on branch `ff` at all times. Never run `git checkout` to another branch like `main` or `fd`).
* **Specialty / Domain:**
  - High-fidelity static HTML / Tailwind UI mockups and prototypes in `ui_mockups/`.
  - In-browser interactive state machines and DOM reactivity engines (e.g., CRUD handlers, time pickers, search filters, state transitions).
  - Built-in automated test runners (`#auto-test-modal`) embedded in every screen with interactive assertion runners.
  - Headless Node.js test verification scripts (`test_code2_screens.js`, `test_planner_screen.js`, `test_usage_stats.js`, etc.).
  - Multi-screen cross-linking via the floating 5-tab pill bottom navigation bar.
* **Collaboration Boundaries & Invariants:**
  - **Code1 Scope:** `Code1` is the Lead UI/Flutter Architect concurrently working on the Flutter backend, SQLite/Hive database, Riverpod providers, and native Flutter screens (`fluxfoxus/lib/`). **DO NOT MODIFY OR OVERWRITE CODE1'S FILES.**
  - **Shared Files:** `agent_worklog.md` and `progress_tracker.md` are shared coordination files. Always update them collaboratively.
  - **No Unprompted Flutter Code:** `Code2` works strictly in HTML/Tailwind prototypes until the user explicitly requests Flutter code implementation.
  - **Mandatory Review Summary Rule (Rule 6):** Whenever submitting completed work to the user for review, you must append a structured 3-part **Review Summary** at the end:
    1. *What exactly you have to review* (specific flows, clicks, and test buttons)
    2. *What you are going to review* (ports, screens, visual tokens, and states)
    3. *What exactly it is* (spec reference, TRD section, IPC purpose, and UX role)

---

## 2. Design System & Token Override (Rustic Medley)

All UI design, CSS classes, SVG fills, and Tailwind configurations must strictly adhere to the **Rustic Medley** palette defined in `ff_design_override.md`. No purples, blues, or cyans from the old spec should ever be used:

| Token Name | Hex Code | Purpose / Mapping |
|---|---|---|
| `color_background` | `#13191F` (River Styx) | Main application background |
| `color_surface` | `#2B2F2E` (Carbon Fibre) | Cards, modals, bottom sheets, navigation pill container |
| `color_surface_elevated` | `#232726` (Elevated Carbon) | Subtle elevations, dark card sub-containers |
| `color_border` | `#594C3D` (Afternoon Tea) | Card borders, dividers, subtle outlines |
| `color_accent` | `#906D4B` (Tanned Wood) | Sub-labels, break display, semi-productive category |
| `color_primary` | `#CA9C68` (Amber Autumn) | Primary action buttons, active tab indicators, flame/streak icons, flip-clock split line |
| `color_text_primary` | `#F8FAFC` (Ghost White) | High-contrast headings, active numerals, primary labels |
| `color_text_muted` | `#94A3B8` (Slate Grey) | Secondary text, inactive tabs, captions, disabled states |
| `category_productive` | `#4E7D56` (Olive Green) | Productive category indicator & completed sessions |
| `category_semi` | `#906D4B` (Tanned Wood) | Semi-productive category indicator |
| `category_distracting` | `#38332B` / `#232726` | Distracting category indicator (carbon charcoal) |
| `category_others` | `#64748B` / `#94A3B8` | Neutral / miscellaneous app category |

---

## 3. Server Ports & Screen Registry

All screens live in `ui_mockups/` and are served via background Python HTTP servers:

| Port | File | Owner | Description |
|---|---|---|---|
| **8085** | `ui_mockups/active_focus_session.html` | `Code1` | Active focus session with mechanical flip-clock and controls |
| **8086** | `ui_mockups/home_screen.html` | `Code2` | Home dashboard, Bézier stacked area chart, momentum legend, session card |
| **8087** | `ui_mockups/preset_creation.html` | `Code1` (C2 redirect) | Preset creation flow, break steppers, YouTube 3-way radio, friction confirmation |
| **8088** | `ui_mockups/app_limits.html` | `Code2` | App limits list (Blocks tab), reactive CRUD engine, dual-column scroll time picker, 3s delay |
| **8089** | `ui_mockups/planner.html` | `Code2` | Planner screen, 7-day calendar strip, session cards, FD sync icon (`↻`), FAB "+ Add Preset" |
| **8090** | `ui_mockups/usage_stats.html` | `Code2` | Usage stats screen, 3 horizons (Today, Daily, Weekly), searchable app list, app detail sheet |

---

## 4. Completed Work & Current State Summary

1. **Home Screen (`home_screen.html` - Port 8086)**:
   - Complete 24h Bézier stacked area chart, momentum legend grid, session card, state switcher.
   - In-browser automated test runner (`#auto-test-modal`) passing 9 assertion gates.
2. **App Limits Screen (`app_limits.html` - Port 8088)**:
   - Reactive in-memory state engine (`renderAppLimits()`) with dynamic Add, Edit, Delete, and Turn-Off DOM updates.
   - Dual-column time picker, 3-second streak delay safeguard, and in-browser automated test runner.
3. **Planner Screen (`planner.html` - Port 8089)**:
   - 7-day horizontal calendar strip with active Amber Autumn styling, today's subtle marker, and inactive days.
   - Completed (0.6 opacity, `#4E7D56` border, `✓` checkmark), Live (`#CA9C68` border, pulsing dot, ticking timer), and Scheduled session cards.
   - `↻` sync icon exclusively for FluxDone (`FD`) blocks.
   - Centered FAB (`+ Add Preset`) clearing the bottom nav bar with bidirectional return linking to `preset_creation.html`.
   - In-browser automated test runner passing 10 assertion gates.
4. **Preset Creation Redirect & Schedule Integration**:
   - `preset_creation.html` now supports `goBack()` and `?returnUrl=planner.html`.
   - Saving a preset stores it in `sessionStorage` and redirects back to `planner.html`, which dynamically injects the newly created preset into the schedule and displays a celebration toast.
5. **Usage Stats Screen (`usage_stats.html` - Port 8090)**:
   - Top bar with back arrow and help modal.
   - 3-tab selector: **Today** (Bézier area chart), **Daily** (7-day stacked bar chart with day selection), **Weekly** (multi-week stacked bar chart + Sunday summary report card).
   - 2×2 category legend grid with dividers.
   - Searchable app section with live filtering, empty state, and interactive App Detail bottom sheet.
   - 10 automated assertion gates passing in `#auto-test-modal`.
6. **Testing & Git Status**:
   - `test_code2_screens.js` passes 100% across all 4 Code2 screens (`home_screen`, `app_limits`, `planner`, `usage_stats`).
   - Clean git state on branch `ff`. Commits pushed to `origin/ff` up to commit `cecc4d3`.

---

## 5. Next Task to Execute (Queued Task)

### Task Name:
**`Refine Usage Stats Screen: Enhance Color Vividness & Adjust Weekly Horizon (Bug Fix & Polish)`**

### Specific Requirements & User Feedback to Address:
1. **Daily View Stacked Bars Color Vividness & Distinctness**:
   - **User Feedback:** *"in daily, the colours in the bars are not as vivid or clear or ditinct as i hope"*
   - **Implementation Goal:**
     - The category segment colors in the daily stacked bars currently appear too dark/muted against the dark background.
     - Increase color saturation, contrast, and visual distinctness for all 4 categories:
       - **Productive:** Crisp, vibrant Olive Green (e.g. `#4E7D56` / `#58A366` with a bright edge/fill).
       - **Semi-Productive:** Rich warm amber/tanned wood (e.g. `#906D4B` / `#B88856`).
       - **Distracting:** Currently `#38332B` blends into the background; make it clearly distinct with a visible outline, warm carbon contrast (e.g. `#C27838` or a defined border/hatching or high-contrast slate `#474036`).
       - **Others:** Clearly readable slate `#64748B` / `#7E8F9F`.
     - Ensure the selected bar pops with a high-contrast glowing outline or vibrant fill, while unselected bars retain a distinct structured greyscale.
2. **Today View Bézier Area Chart Vividness**:
   - **User Feedback:** *"same issue in today as well"*
   - **Implementation Goal:**
     - Make the 4 Bézier stacked area layers in `view-chart-today` significantly more vivid and distinct.
     - Use higher-opacity gradients and crisp colored stroke outlines (`stroke="#4E7D56"`, `stroke="#906D4B"`, `stroke="#C27838"`, `stroke="#64748B"`, stroke-width 1.5–2px) along each curve ridge so the boundaries between categories are sharp and easily readable.
3. **Weekly View Horizon: 7 Days / Bars Adjustment**:
   - **User Feedback:** *"IN week why is it 5 days? it should be 7 days."*
   - **Implementation Goal:**
     - In `ui_usage_stats.md` Section 7.1, the spec mentioned "5 most recent weeks", which displayed 5 bars. However, the user expected **7 items** (either 7 rolling weeks or 7 weekly aggregate bars to match the 7-column layout of the daily view).
     - Update the weekly chart dataset and rendering to feature **7 distinct bars** (e.g., 7 rolling weeks: `Feb 9`, `Feb 16`, `Feb 23`, `Mar 2`, `Mar 9`, `Mar 16`, `Mar 23`) or a 7-day multi-week aggregated comparison so the visual rhythm consistently spans 7 columns.
     - Ensure all 7 bars are rendered with the enhanced vivid category colors and clean X-axis labels.
4. **Automated Tests & Regression Verification**:
   - Update `test_usage_stats.js` and `test_code2_screens.js` to assert the 7-bar count in the weekly view.
   - Run in-browser automated tests in `#auto-test-modal` and verify 100% passing rate.
   - Perform `raupwfiles` (`agent_worklog.md` and `progress_tracker.md`) before and after the fix.
   - Commit and push changes cleanly to `origin/ff`.

---

## 6. How to Resume Work as `Code2`

When resuming in this codespace or a new session:
1. Verify branch is `ff`: `git branch` (must show `* ff`).
2. Run automated test suite: `node test_code2_screens.js`.
3. Check running background HTTP servers:
   - Port 8086: `python3 -m http.server 8086 --directory ui_mockups`
   - Port 8088: `python3 -m http.server 8088 --directory ui_mockups`
   - Port 8089: `python3 -m http.server 8089 --directory ui_mockups`
   - Port 8090: `python3 -m http.server 8090 --directory ui_mockups`
4. Update `agent_worklog.md` and `progress_tracker.md` to set `Code2` status to `ACTIVE` for the Usage Stats visual refinement task.
5. Apply the edits to `ui_mockups/usage_stats.html` (vivid strokes/gradients in Today Bézier chart, vivid bar colors in Daily view, and 7 bars in Weekly view).
6. Run `node test_usage_stats.js` and `node test_code2_screens.js`.
7. Commit cleanly with `git commit -m "fix(ui): enhance color contrast and update weekly horizon to 7 bars in usage stats"` and run `git push origin ff`.
8. Provide the review response with the mandatory 3-part **Review Summary**.
