# Features Implemented

> **Last Updated:** 2026-10-10
> **Source:** Code1 commits on `ff` branch, `progress_tracker.md`, `agent_worklog.md`

---

## Phase 1-A: Foundation (Complete ✅)

### Step 1 — Design Tokens & Theme

**What it does:** Establishes the complete visual design system as Flutter constants and `ThemeData`.

**Files:**
- `lib/core/theme/theme_tokens.dart` — Rustic Medley colour tokens
- `lib/core/theme/app_typography.dart` — Inter font typography scales
- `lib/core/theme/app_spacing.dart` — 4px base grid spacing constants
- `lib/core/theme/app_radius.dart` — Corner radius constants
- `lib/core/theme/app_theme.dart` — Dark-only `ThemeData` (flat 2D, zero elevation)
- `lib/core/theme/theme.dart` — Barrel export
- `lib/core/theme/responsive_layout.dart` — `AppBreakpoints`, `ResponsiveContent`, `AdaptiveScrollBody`

**Tests:** `test/core/theme/theme_tokens_test.dart` (5 tests)

---

### Step 2 — Database & Hive Persistence

**What it does:** Sets up all persistence layers — SQLite with 6 tables, Hive with 4 boxes.

**Files:**
- `lib/core/database/app_database.dart` — `AppDatabase` class managing SQLite lifecycle (singleton, lazy init, `sqflite`)
- `lib/core/database/database_tables.dart` — `DatabaseTables` with all DDL SQL strings and column name constants

**Tests:**
- `test/core/database/app_database_test.dart` (part of 11 total tests)
- `test/core/storage/hive_storage_service_test.dart`

---

### Step 3 — Navigation Shell

**What it does:** Full GoRouter setup with 5-tab floating pill navigation bar and full-screen session takeover.

**Files:**
- `lib/core/navigation/app_router.dart` — `createAppRouter()`, `routerProvider`
- `lib/core/navigation/app_routes.dart` — `AppRoutes` path constants
- `lib/core/navigation/scaffold_with_nav_bar.dart` — Shell scaffold wrapping `StatefulShellRoute`
- `lib/core/navigation/floating_bottom_nav_bar.dart` — 5-tab pill nav (Home, Usage, Focus, Planner, Block)
- `lib/core/navigation/aperture_icon.dart` — Custom FF camera aperture brand icon
- `lib/core/navigation/navigation.dart` — Barrel export

**Navigation design:**
- 5 tabs: Home (`/`), Usage (`/usage`), Focus (`/focus`), Planner (`/planner`), Block (`/blocks`)
- Tab grouping in pill: [Usage + Focus] left pair, [Planner + Block] right pair, Home standalone center
- `/focus/session` is a root-level route — hides nav bar (full-screen takeover)

**Tests:** `test/core/navigation/navigation_test.dart` (10 tests)

---

### Step 4 — Permissions Onboarding

**What it does:** First-launch 4-step wizard to request all required Android permissions.

**Files:**
- `lib/core/permissions/app_permission.dart` — `AppPermission` enum + `PermissionDetails` metadata
- `lib/core/permissions/permission_service.dart` — `PermissionService` abstraction + `DefaultPermissionService`
- `lib/core/permissions/permissions.dart` — Barrel export
- `lib/presentation/screens/onboarding_screens.dart` — `PermissionsOnboardingFlowScreen`, `UsageStatsPermissionScreen`, `AccessibilityPermissionScreen`

**4-step wizard order:**
1. `POST_NOTIFICATIONS` — Standard runtime permission
2. `PACKAGE_USAGE_STATS` — Redirects to system Settings
3. `SYSTEM_ALERT_WINDOW` — Redirects to system Settings
4. `ACCESSIBILITY_SERVICE` — Redirects to accessibility Settings

**Tests:** `test/core/permissions/permission_service_test.dart` + `test/presentation/screens/onboarding_screens_test.dart` (13 tests)

---

## Phase 1-B: Core Focus System (Steps 5–8 Complete ✅)

### Step 5 — Preset System

**What it does:** Full preset CRUD (create/read/update/delete), preset creation UI, and emoji picker.

**Files:**
- `lib/features/presets/domain/preset.dart` — `Preset` model (id, name, emoji, breakCount, breakDurationMinutes, youtubeMode, description)
- `lib/features/presets/domain/preset_app_restriction.dart` — `PresetAppRestriction` model
- `lib/features/presets/domain/youtube_mode.dart` — `YouTubeMode` enum: `block`, `allow`, `studyMode`
- `lib/features/presets/data/presets_repository.dart` — SQLite CRUD: `getAllPresets()`, `savePreset()`, `updatePreset()`, `deletePreset()`, `getLastUsedPreset()`
- `lib/features/presets/presentation/presets_provider.dart` — `presetsListProvider`, `currentPresetProvider`, `presetsRepositoryProvider`, `appDatabaseProvider`, `hiveStorageServiceProvider`
- `lib/features/presets/presentation/widgets/emoji_picker_sheet.dart` — Searchable emoji bottom sheet
- `lib/features/presets/presets.dart` — Barrel export
- `lib/presentation/screens/preset_create_screen.dart` — Full creation UI per `ui_preset.md`
- `lib/presentation/screens/preset_edit_screen.dart` — Edit screen stub
- `lib/presentation/screens/channel_whitelist_screen.dart` — YouTube channel whitelist screen stub

**Key behaviours:**
- Break steppers: 0–6 breaks, 1–15 min duration
- App restrictions: 4 category cards (Productive, Semi-Productive, Distracting, Others), collapsible
- YouTube 3-way radio: Block / Allow / Study Mode
- Emoji picker: searchable, bottom sheet

**Tests:** `test/features/presets/presets_repository_test.dart` (5) + `test/presentation/screens/preset_create_screen_test.dart` (7) = 12 tests

---

### Step 6 — Focus Timer + Foreground Service

**What it does:** Complete focus session state machine with 3 timer modes, Hive persistence, foreground service, and flip clock UI.

**Files:**
- `lib/features/focus/domain/focus_session.dart` — `FocusSession` immutable model (id, presetId/Name/Emoji, timerMode, status, elapsed, targetDuration, breaks, breakElapsed, timestamps)
- `lib/features/focus/domain/timer_mode.dart` — `TimerMode` enum: `countdown`, `stopwatch`, `openEnded`
- `lib/features/focus/domain/session_status.dart` — `SessionStatus` enum: `pending`, `running`, `paused`, `onBreak`, `completed`, `abandoned`
- `lib/features/focus/data/focus_session_repository.dart` — `FocusSessionRepository`: Hive active session I/O + SQLite finished session logging
- `lib/features/focus/data/streak_repository.dart` — Streak repository stub
- `lib/features/focus/services/foreground_timer_service.dart` — `ForegroundTimerService` abstraction + `DefaultForegroundTimerService` (flutter_foreground_task) + `FakeForegroundTimerService` for testing
- `lib/features/focus/presentation/focus_session_notifier.dart` — `FocusSessionNotifier` state machine + `focusSessionProvider`
- `lib/features/focus/focus.dart` — Barrel export
- `lib/presentation/widgets/flip_clock.dart` — Mechanical split-line flip clock widget
- `lib/presentation/screens/focus_session_screen.dart` — Full-screen focus session UI

**Timer mechanics (drift-free):**
- Running: tracks `lastResumedAt` timestamp; each tick computes `now - lastResumedAt` as delta.
- Break: tracks `lastBreakStartedAt`; same delta approach.
- Auto-save to Hive every 5 ticks (5 seconds).
- On app restart: reads Hive active session, recalculates elapsed from wallclock diff.

**Foreground notification:**
- Channel ID: `focus_session_timer`
- Title: `{emoji} {presetName}` during focus, `☕ Break Time — {presetName}` during break
- Text: countdown remaining or elapsed

**FlipClock widget:**
- Two rounded square cards: HH (top), MM (bottom)
- Horizontal amber split seam line (`#CA9C68`) for mechanical illusion
- Digits in `ThemeTokens.textPrimary`; break mode shifts to `ThemeTokens.accent`

**Tests:** 24 new tests (session model, notifier, flip clock, screen) — see `07_testing_registry.md`

---

### Step 7 — Break System

**What it does:** Full break lifecycle including countdown display, exhaustion state, "End Break Early", and auto-resume.

**Key behaviours in `FocusSessionNotifier`:**
- `startBreak()`: guarded by `canTakeBreak`, increments `breaksTaken`, emits haptic medium impact
- `endBreak()`: emits haptic heavy impact, resumes focus running state
- Auto-break expiry: `_tick()` detects when `breakElapsed >= breakDuration` and calls `endBreak()`
- Break exhaustion: when `breaksTaken >= breaksTotal`, `canTakeBreak` is false → Break button becomes greyscale/non-interactive in UI

**Break button states in `FocusSessionScreen`:**
- `breaksTotal == 0`: Button absent entirely
- `canTakeBreak == true`: Active outline button, shows remaining count
- `canTakeBreak == false`: `Opacity(0.4)` + `IgnorePointer` — greyscale, non-interactive
- `status == onBreak`: Button transforms to "End Break Early" in `#CA9C68`; Pause button hidden

**ClockColor in break mode:** Digits and seam shift to `ThemeTokens.accent` (`#906D4B` Tanned Wood)

**Tests:** `test/features/focus/break_system_test.dart` (5 tests)

---

### Step 8 — Stop Focusing Modal (Discipline Friction)

**What it does:** Friction modal preventing impulsive session abandonment. Formula-driven countdown delay (15–25s) before action buttons unlock.

**Files:**
- `lib/features/focus/domain/wait_time_calculator.dart` — `WaitTimeCalculator.calculateWaitSeconds()`
- `lib/presentation/widgets/stop_focusing_modal.dart` — `StopFocusingModal` widget

**Wait time formula (TRD §5.3.3):**
```
waitSeconds = (streakWeight × 25) + (usageWeight × 25 × usageRatio)
clamped to [15, 25] seconds
usageRatio = todayDistractingUsage / avgDistractingUsage (clamped 0.0–1.0)
```

Weight lookup by streak length:
| Streak | streakWeight | usageWeight |
|---|---|---|
| < 10 days | 0.55 | 0.45 |
| 10–20 days | 0.45 | 0.55 |
| 21–29 days | 0.40 | 0.60 |
| 30–44 days | 0.25 | 0.75 |
| 45–59 days | 0.15 | 0.85 |
| 60–99 days | 0.10 | 0.90 |
| ≥ 100 days | 0.00 | 1.00 |

**Modal UI:**
- Alert bell icon in `#CA9C68` circle
- "Finish the goal?" heading + streak warning subtitle
- Streak row: [Amber dot] X days → [Grey dot] 0 days
- Two action buttons side-by-side, both 35% opacity until countdown reaches 0
- "Keep Going" (primary, `#CA9C68`) — closes modal, resumes session
- "Quit Session (Xs)" (secondary, outlined `#906D4B`) — live countdown in label until unlocked

**Tests:** `test/presentation/widgets/stop_focusing_modal_test.dart` + `test/features/focus/wait_time_calculator_test.dart`

---

## Responsive Layout System (Phase 1-A & 1-B Step 5)

**Files:**
- `lib/core/theme/responsive_layout.dart`
- `test/responsive_test.dart` — 48 assertions across 6 viewport profiles

All implemented screens use `ResponsiveContent` to constrain width on tablets, and `AdaptiveScrollBody` for landscape mode scrollability.

---

## Summary Table

| Step | Phase | Status | Tests |
|---|---|---|---|
| Step 1: Design Tokens | 1-A | ✅ Done | 5 |
| Step 2: Database & Hive | 1-A | ✅ Done | 11 |
| Step 3: Navigation Shell | 1-A | ✅ Done | 10 |
| Step 4: Permissions Onboarding | 1-A | ✅ Done | 13 |
| Step 5: Preset System | 1-B | ✅ Done | 12 |
| Responsive Layout System | 1-A/B | ✅ Done | 48 |
| Step 6: Focus Timer + Foreground | 1-B | ✅ Done | 24 |
| Step 7: Break System | 1-B | ✅ Done | 5 |
| Step 8: Stop Focusing Modal | 1-B | ✅ Done | ~8 |
| Steps 9–22 | 1-B to 1-G | ⏳ Backlog | — |

**Total Flutter test suite: 128/128 + 48 responsive = 176 assertions, 0 lints**
