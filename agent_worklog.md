# Multi-Agent Coordination Registry (`agent_worklog.md`)

This registry coordinates concurrent/subsequent AI coding agents working in this repository.  
**Rule for all agents:** Before picking up any task or modifying files, check this file. Register your agent name, active scope, and reserved files below. Keep this file updated when starting or finishing work.

---

## 1. Active Agents Registry

| Agent Name | Role / Specialty | Status | Branch | Current Task / Active Scope | Reserved / Active Files | Port(s) Used |
|---|---|---|---|---|---|---|
| **Code1** | Lead UI Designer | **ACTIVE** | `ff` | Phase 1-A Step 4: Permissions Onboarding Flow (plain-language explanation screens & system intent handlers for POST_NOTIFICATIONS, PACKAGE_USAGE_STATS, SYSTEM_ALERT_WINDOW, and ACCESSIBILITY_SERVICE per TRD Section 7). | `fluxfoxus/lib/core/permissions/`, `fluxfoxus/lib/presentation/screens/onboarding_screens.dart`, `progress_tracker.md`, `agent_worklog.md` | `8085` |
| **Code2** | Companion UI Designer | **ACTIVE** | `ff` | Refinement & Reactivity: (1) Add in-browser automated tests to `home_screen.html` (backend requirements, rolling metrics, state assertions); (2) Fix DOM reactivity for Add, Delete, Edit, and Turn-Off flows in `app_limits.html` with test runner. | `ui_mockups/home_screen.html`, `ui_mockups/app_limits.html`, `progress_tracker.md`, `agent_worklog.md` | `8086`, `8088` |

---

## 2. Agent Details & Active Context

### Agent: `Code1`
* **Assigned Identity:** `Code1`
* **Role:** Lead UI Designer
* **Current Working Branch:** `ff` (Strict branch lock — DO NOT SWITCH BRANCHES)
* **Status:** `ACTIVE` (In-progress)
* **Completed:**
  - Built static HTML/Tailwind preview of the **Active Focus Session Screen** (`ui_mockups/active_focus_session.html`) with split-line mechanical flip-clock, bottom controls, and Rustic Medley palette override.
  - Preview reviewed and approved by user.
  - Added and resolved all Flutter dependencies in `fluxfoxus/pubspec.yaml` (runtime + dev).
  - Configured Android `minSdkVersion = 26` and `targetSdkVersion = 34` in `android/app/build.gradle.kts`.
  - Implemented the complete Flutter Design System & ThemeTokens in `fluxfoxus/lib/core/theme/`:
    - `theme_tokens.dart` (Rustic Medley: `#13191F`, `#2B2F2E`, `#594C3D`, `#906D4B`, `#CA9C68`, `#F8FAFC`, `#94A3B8`).
    - `app_typography.dart` (Inter typography scales from `type_display` to `type_micro`).
    - `app_spacing.dart` (4px base grid).
    - `app_radius.dart` (Corner radiuses).
    - `app_theme.dart` (Dark-only `ThemeData`, flat 2D zero-elevation).
    - `theme.dart` (Barrel export).
  - Configured `fluxfoxus/lib/main.dart` with `ProviderScope` and `AppTheme.darkTheme`.
  - Added unit test suite `test/core/theme/theme_tokens_test.dart` (5 tests passing, `flutter analyze` 100% clean).
  - Implemented Phase 1-A Step 2: Database & Storage:
    - SQLite schema & tables (`presets`, `preset_app_restrictions`, `focus_sessions`, `app_limits`, `streak_records`, `study_channels`) with foreign key cascade delete and performance indexes (`app_database.dart`, `database_tables.dart`).
    - Hive storage service (`hive_storage_service.dart`) with boxes for `preferences`, `app_categories`, and `app_metadata`.
    - Automated unit tests (`app_database_test.dart`, `hive_storage_service_test.dart`) — 11 tests passing, 0 lints.
  - Implemented Phase 1-A Step 3: Navigation Shell:
    - `go_router` declarative routes per TRD Section 6 (`/`, `/usage`, `/focus`, `/focus/session`, `/planner`, `/planner/preset/create`, `/planner/preset/:id/edit`, `/planner/preset/:id/channels`, `/blocks`, and permission onboarding routes).
    - Floating 5-tab pill navigation bar matching `ui_navigation.md` and Rustic Medley tokens (`#2B2F2E` surface, `#594C3D` border, `#CA9C68` active primary, `#94A3B8` inactive muted, 28px pill radius, 16px margins).
    - Visual sub-container pill grouping for [Usage + Focus] and [Planner + Block], Home standalone.
    - Full-screen takeover behavior: bottom navigation bar is automatically hidden on `/focus/session` and restored upon returning to Home.
    - Custom camera aperture icon (`ApertureIcon`) for FF brand tab.
    - Complete screen widgets with proper semantic structure and Rustic Medley theme integration.
    - 10 automated unit & widget tests in `navigation_test.dart` + root smoke test in `widget_test.dart` (26 tests total passing across all suites).
    - Static analysis: `flutter analyze` 100% clean with 0 issues.
* **What `Code1` is doing right now:**
  - Implementing Phase 1-A Step 4: Permissions Onboarding Flow:
    - Service and state management for checking and requesting critical permissions per TRD Section 7:
      1. `POST_NOTIFICATIONS` (runtime permission)
      2. `PACKAGE_USAGE_STATS` (system settings redirect)
      3. `SYSTEM_ALERT_WINDOW` (system settings redirect)
      4. `ACCESSIBILITY_SERVICE` (accessibility settings redirect)
    - Interactive plain-language onboarding flow with status tracking.
    - Unit and widget tests for permission service and onboarding screens.
* **Next Steps for `Code1`:**
  - Proceed with Phase 1-B Step 5: Preset System (Presets CRUD in SQLite, creation screen with steppers, emoji selector, category app restrictions, YouTube 3-way radio).
* **Exclusive Resources / Do Not Overwrite:**
  - `fluxfoxus/lib/core/permissions/`
  - `fluxfoxus/lib/presentation/screens/onboarding_screens.dart`
  - `progress_tracker.md` (Update collaboratively)
  - `agent_worklog.md` (Update collaboratively)
  - Port `8085` (Preview server remains up)

### Agent: `Code2`
* **Assigned Identity:** `Code2`
* **Role:** Companion UI Designer
* **Current Working Branch:** `ff` (Strict branch lock — DO NOT SWITCH BRANCHES)
* **Status:** `ACTIVE` (In-progress)
* **Completed:**
  - Built static HTML/Tailwind preview of the **Home Screen** (`ui_mockups/home_screen.html`) with 24h Bézier stacked area chart, momentum legend grid, preset selector, and floating 5-tab pill nav bar. Preview served on port `8086`, reviewed and approved by user.
  - Built static HTML/Tailwind preview of the **Preset Creation & Channel Whitelist Screen** (`ui_mockups/preset_creation.html`) with break steppers, collapsible app restrictions, YouTube 3-way radio, and discipline friction confirmation typing flow. Preview served on port `8087`, verified with automated test runner by C1.
  - Built static HTML/Tailwind preview of the **App Limits (Blocks Tab) Screen** (`ui_mockups/app_limits.html`), served on port `8088`.
* **What `Code2` is doing right now:**
  1. **Home Screen Automated Test Suite**:
     - Adding an in-browser automated test runner (`#auto-test-modal`) to `ui_mockups/home_screen.html`.
     - Validates backend requirements, rolling metric averages (Focused vs Weekly), 24h area chart layer ordering, 4 state transitions (Standard, Active Session Running, Upcoming 15m alert, Empty state), and FD ↔ FF IPC hooks (`com.fluxfoxus/fd_integration`).
  2. **App Limits Screen Reactivity & DOM Mutation Fixes**:
     - Investigating and fixing DOM reactivity in `ui_mockups/app_limits.html`:
       - **Add App**: dynamically creates and appends new app cards to their proper category group.
       - **Edit & Save**: dynamically updates card limit values, spent times, and active streaks.
       - **Turn-off Limit**: dynamically switches badge from "Blocking" to "Paused" and adds "Turned off till [timestamp]".
       - **Delete Limit**: dynamically removes the card from the UI.
     - Adding an in-browser automated test runner modal to verify all limit CRUD and lifecycle mutations.
  3. Strict constraint: No Flutter code written until explicitly requested; focus strictly on perfecting HTML/Tailwind screens and dynamic mockups.
* **Exclusive Resources / Do Not Overwrite:**
  - `ui_mockups/home_screen.html` (Code2 screen)
  - `ui_mockups/app_limits.html` (Code2 screen)
  - Port `8086` (Home Screen preview)
  - Port `8088` (App Limits preview)

---

## 3. Protocol for EVERY Agents (e.g. `Code1`, `Backend1`, `Code2` etc.)

1. **Check this Registry:** Read `agent_worklog.md` before claiming or executing any task.
2. **Register Your Agent:** Add a row to the table in Section 1 with your assigned name, role, status (`ACTIVE`), and target scope.
3. **Branch Invariant:** **STAY ON BRANCH `ff`**. Do NOT switch to `main`, `fd`, or any other branch under any circumstances.
4. **Coordinate File Access:** If you are working on the Flutter app backend, SQLite/Hive storage, or other feature specs, make sure not to overwrite files claimed by other active agents.
5. **Update Upon Completion:** When your task is finished, update your status to `IDLE` or `COMPLETED`.
