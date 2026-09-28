# FluxFoxus (FF) — User Review Backlog

**Target Audience:** User / Project Lead  
**Branch:** `ff`  
**Generated:** March 2026  
**Status:** Queued for User Review  

---

## 1. Interactive UI Previews (Browser / Codespaces)

The preview server `serve_mockups.py` is running in your Codespace background. To view any preview, open the **Ports** panel in the bottom dock of VS Code / Codespaces (next to Terminal / Output) and click the **Globe icon (Open in Browser)** on the relevant port.

### Priority 1: Unified Multi-Screen Review Hub (`Port 8080`)
* **URL:** `http://localhost:8080` (or click port `8080` in Codespaces Ports tab)
* **File:** [`ui_mockups/index.html`](file:///workspaces/The_Flux/ui_mockups/index.html)
* **What to verify:**
  - [ ] **Screen Selector**: Switch seamlessly between 🏠 **Home**, ⏱️ **Focus Session**, 📅 **Planner**, ⚙️ **Preset System**, 🚫 **App Limits**, and 📊 **Usage Stats**.
  - [ ] **Responsive Viewport Profiles**: Test adaptive scaling on:
    - 📱 Narrow Phone (320 × 568)
    - 📱 Standard Phone (390 × 844)
    - 🔄 Landscape Compact (640 × 360)
    - 🔄 Landscape Standard (844 × 390)
    - 📱 Tablet Portrait (768 × 1024)
    - 💻 Tablet Landscape (1024 × 768)
    - 🖥️ Full Viewport
  - [ ] **Orientation Flip & Scaling**: Click `🔄 Flip Orientation` and test zoom dropdown (50% to 100%).

---

### Priority 2: Individual Screen Deep-Dives

#### A. Active Focus Session (`Port 8085`)
* **URL:** `http://localhost:8085` | **File:** [`ui_mockups/active_focus_session.html`](file:///workspaces/The_Flux/ui_mockups/active_focus_session.html)
* **Owner:** Code1
* **What to verify:**
  - [ ] Mechanical split-line flip clock (HH:MM cards with Amber Autumn `#CA9C68` horizontal seam line & recessed hinge notches).
  - [ ] Header pill with preset name and emoji (`⚡ Deep Work`).
  - [ ] Break mode styling shift: digits change to Tanned Wood (`#906D4B`) and header displays `BREAK`.
  - [ ] Tap **Stop Focusing**: Verify the interactive Discipline Friction modal triggers with live countdown timer and streak warning before allowing quit.
  - [ ] Tap **Pause / Play** circle and **Break** button.

#### B. Home Screen (`Port 8086`)
* **URL:** `http://localhost:8086` | **File:** [`ui_mockups/home_screen.html`](file:///workspaces/The_Flux/ui_mockups/home_screen.html)
* **Owner:** Code2
* **What to verify:**
  - [ ] 24-hour smooth Bézier stacked area chart (~200px height) showing 4 activity categories.
  - [ ] 2×2 momentum legend grid with subtle dividers.
  - [ ] Session Card with preset details and primary pill button ("Start Focusing" in `#CA9C68`).
  - [ ] Floating 5-tab bottom navigation pill bar with camera aperture icon for FF brand tab.
  - [ ] State Switcher at top (Standard, Active Running, 15m Alert, Empty).

#### C. Preset Creation & Study Mode Channel Whitelist (`Port 8087`)
* **URL:** `http://localhost:8087` | **File:** [`ui_mockups/preset_creation.html`](file:///workspaces/The_Flux/ui_mockups/preset_creation.html)
* **Owner:** Code1
* **What to verify:**
  - [ ] Preset Name input with emoji selector trigger.
  - [ ] Break configuration 2-card grid (0–6 breaks, 1–15 min steppers).
  - [ ] Collapsible app restriction category cards with toggle switches.
  - [ ] YouTube 3-way radio (Block / Allow / Study Mode).
  - [ ] Channel Whitelist sheet with friction confirmation sentence typing flow.

#### D. App Limits (Blocks Tab) (`Port 8088`)
* **URL:** `http://localhost:8088` | **File:** [`ui_mockups/app_limits.html`](file:///workspaces/The_Flux/ui_mockups/app_limits.html)
* **Owner:** Code2
* **What to verify:**
  - [ ] App limit cards grouped by category with spending vs limit progress.
  - [ ] Add App & Edit App bottom sheets with dual-column scroll time picker and extra time sessions.
  - [ ] Turn Off Block flow: streak warning sheet (`🔥` to `🌧️`) with 3-second delay button and duration picker.

#### E. Planner Screen (`Port 8089`)
* **URL:** `http://localhost:8089` | **File:** [`ui_mockups/planner.html`](file:///workspaces/The_Flux/ui_mockups/planner.html)
* **Owner:** Code2
* **What to verify:**
  - [ ] 7-day horizontal scrollable calendar strip with active, today, and inactive states.
  - [ ] Daily stats row: Focus total vs Usage screen time.
  - [ ] Session cards (Completed with green accent `✓`, Active with live ticking timer, Scheduled with planned duration).
  - [ ] FD sync source badge (`↻`) vs native FF presets.

#### F. Usage Stats Screen (`Port 8090`)
* **URL:** `http://localhost:8090` | **File:** [`ui_mockups/usage_stats.html`](file:///workspaces/The_Flux/ui_mockups/usage_stats.html)
* **Owner:** Code2
* **What to verify:**
  - [ ] 3-tab selector: Today (24h area chart), Daily (7-day bar chart), Weekly (7-week bar chart + Sunday In-App Summary Card).
  - [ ] Searchable app list with descending time spent and app detail sheets.

---

## 2. Flutter Production Codebase Review

All production Flutter code is implemented on branch `ff` inside `fluxfoxus/`.

### Completed Modules & Test Verification:
1. **Design System & Theme Tokens** (`fluxfoxus/lib/core/theme/`):
   - Strict Rustic Medley palette (`#13191F`, `#2B2F2E`, `#594C3D`, `#906D4B`, `#CA9C68`, `#F8FAFC`, `#94A3B8`). Zero blues/purples, flat 2D zero-elevation.
2. **Database & Storage** (`fluxfoxus/lib/core/database/`, `fluxfoxus/lib/core/storage/`):
   - SQLite 6 tables with foreign keys and performance indexes; Hive boxes for user preferences, category overrides, app metadata, and focus session state.
3. **Navigation Shell** (`fluxfoxus/lib/core/navigation/`):
   - `go_router` declarative routes with 5-tab floating pill bar and full-screen takeover hide logic on active focus session.
4. **Permissions Onboarding** (`fluxfoxus/lib/core/permissions/`, `fluxfoxus/lib/presentation/screens/onboarding_screens.dart`):
   - 4-step wizard for notifications, usage stats, system alert window, accessibility service.
5. **Preset System** (`fluxfoxus/lib/features/presets/`, `fluxfoxus/lib/presentation/screens/preset_create_screen.dart`):
   - SQLite CRUD, interactive creation screen, break steppers, category app restrictions, YouTube 3-way radio.
6. **Focus Timer & Foreground Service** (`fluxfoxus/lib/features/focus/`, `fluxfoxus/lib/presentation/screens/focus_session_screen.dart`):
   - Drift-free delta timing (`FocusSession`), Hive 5-second auto-save, SQLite finished session logging, `ForegroundTimerService` with `flutter_foreground_task`, `FocusSessionNotifier` state machine, mechanical split-line `FlipClock` widget.

### Quality Gates Verified:
- **`flutter test`**: **123/123 tests passing (100%)**
- **`flutter test test/responsive_test.dart`**: **48/48 layout tests passing (100%)**
- **`flutter analyze`**: **0 issues found** (0 errors, 0 warnings, 0 lints)
- **Git status**: Clean, pushed to `origin/ff`.

---

## 3. How to Execute Tests Locally

To re-run all automated verification anytime:

```bash
cd /workspaces/The_Flux/fluxfoxus
/home/codespace/flutter/bin/flutter test
/home/codespace/flutter/bin/flutter test test/responsive_test.dart
/home/codespace/flutter/bin/flutter analyze
```
