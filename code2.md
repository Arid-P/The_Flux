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
6. **Usage Stats Color Vividness & 7-Week Horizon (Completed)**:
   - Daily stacked bars enhanced with high-contrast vivid Rustic Medley category colors (`#58A366`, `#B88856`, `#C27838`, `#7E8F9F`).
   - Today Bézier stacked area chart refined with high-opacity gradients and crisp stroke outlines.
   - Weekly horizon updated to 7 rolling weeks.
7. **Review Hub Viewport Preservation & Island Navigation Bridge (Completed)**:
   - Resolved issue where navigating via the floating bottom island caused screens to revert to a mobile ratio or stale cached markup.
   - Implemented `navigateTo(url)` bridge across all 6 screens (`home_screen.html`, `planner.html`, `usage_stats.html`, `app_limits.html`, `active_focus_session.html`, `preset_creation.html`) with cross-frame `window.parent.selectScreen` and timestamp-based cache busting (`?t=Date.now()`).
   - Configured `#device-bezel` with `box-sizing: content-box` in `index.html` ensuring genuine 768px inner viewport triggers responsive `@media (min-width: 768px)` Tailwind breakpoints cleanly.
   - Configured automatic iframe `load` listener in `index.html` to sync active top header tabs and standalone link upon any screen navigation.
   - Removed redundant `min-h-screen` container styles across screens to prevent vertical layout overflow.
8. **Testing & Git Status**:
   - `test_code2_screens.js` passes 100% across all 6 sections (Home, App Limits, Planner, Usage Stats, Limits CRUD, Hub Bridge).
   - `test_planner_screen.js`, `test_preset_creation.js`, `test_usage_stats.js` all pass 100%.
   - All 48 Flutter responsive layout tests pass (100%).

---

## 5. Next Task to Execute (Queued Task)

* **Status:** `IDLE` (Task completed & verified).
* **Completed Task:** `Distraction Intervention & YouTube Study Mode UI Mockup`
  - Created `ui_mockups/distraction_intervention.html` per `prompts_docx/FLUXFOXUS/Phase 1/ui_distracted_intervention.md` and `ff_design_override.md`.
  - Implemented 2/5/10/20 bottom-sheet intervention overlay on top of blurred app content.
  - Interactive state machine: App switching (Instagram, YouTube, Reddit), time option selection (2m, 5m, 10m, 20m), session countdown timer, post-duration cooldown lock (5s, 10s, 15s wait periods with disabled buttons).
  - YouTube Study Mode Card & Edge Grabber (~32px x 80px vertical pill with aperture icon expanding into horizontal control panel).
  - Non-whitelisted channel interception banner with friction confirmation sentence typing flow.
  - In-browser `#auto-test-modal` assertion runner (10/10 gates passing).
  - Integrated into `ui_mockups/index.html` (port 8080 unified review hub) with 🛡️ Intervention tab.
  - Test suites: `test_intervention_screen.js` (100% pass) and `test_code2_screens.js` (Section 7 added, 100% pass).
* **Subsequent Backlog Tasks:**
  - Home Widget mockup (`ui_widget.md` -> `ui_mockups/widget.html`).
  - Integration with native Flutter screens as directed by user.

---

## 6. How to Resume Work as `Code2`

When resuming in this codespace or a new session:
1. Verify branch is `ff`: `git branch` (must show `* ff`).
2. Run automated test suite: `node test_code2_screens.js`.
3. Check running background HTTP preview server on port `8080`: `python3 serve_mockups.py`.
4. Update `agent_worklog.md` and `progress_tracker.md` to coordinate with other agents.
5. Provide the review response with the mandatory 3-part **Review Summary**.
