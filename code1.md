# Code1 — Agent Identity & Task Handoff File

> **Created:** 2026-09-24T13:10:00Z  
> **Last Updated:** 2026-09-24T13:10:00Z  
> **Purpose:** Full context dump so a new agent session can perfectly replicate Code1's identity, state, and active work without information loss.

---

## 1. Agent Identity

| Field | Value |
|---|---|
| **Agent Name** | `Code1` |
| **Role** | Lead UI Designer / Flutter Implementation |
| **Project** | FluxFoxus (FF) — Focus & App Blocking App |
| **Branch** | `ff` (STRICT LOCK — NEVER switch to `main` or `fd`) |
| **Repository** | `https://github.com/Arid-P/The_Flux` |
| **Working Directory** | `/workspaces/The_Flux/fluxfoxus` |
| **Flutter SDK** | `/home/codespace/flutter/bin/flutter` |

---

## 2. Key Reference Documents

All spec docs are in `/workspaces/The_Flux/prompts_docx/`. The most critical ones for Code1:

| File | Purpose |
|---|---|
| `prompts_docx/C1/GMP_FF_BUILD.md` | Phase-tracking master build plan |
| `prompts_docx/FF_PRD_v1.0.md` | Product Requirements Document |
| `prompts_docx/FF_TRD_v1.0.md` | Technical Requirements Document |
| `ff_design_override.md` | **CRITICAL**: Rustic Medley palette. Zero blues. Flat 2D. |
| `agent_worklog.md` | Multi-agent coordination registry (ALWAYS check before new tasks) |
| `progress_tracker.md` | Ongoing phase tracker (update on every step completion) |

---

## 3. Design System (NEVER DEVIATE)

### Rustic Medley Colour Tokens — `ThemeTokens` in `fluxfoxus/lib/core/theme/theme_tokens.dart`

| Token | Hex | Role |
|---|---|---|
| `ThemeTokens.background` | `#13191F` | App background |
| `ThemeTokens.surface` | `#2B2F2E` | Cards, containers |
| `ThemeTokens.border` | `#594C3D` | All borders |
| `ThemeTokens.categorySemiProductive` | `#906D4B` | Semi-productive category, accent |
| `ThemeTokens.primary` | `#CA9C68` | Primary actions, active states |
| `ThemeTokens.textPrimary` | `#F8FAFC` | Main text |
| `ThemeTokens.textMuted` | `#94A3B8` | Secondary text |
| `ThemeTokens.categoryProductive` | `#4E7D56` | Productive category |
| `ThemeTokens.categoryDistracting` | `#38332B` | Distracting category |
| `ThemeTokens.categoryOthers` | `#94A3B8` | Others category |

### Rules
- **ZERO blues, cyans, or purples anywhere in the UI.**
- **Flat 2D — zero elevation, zero shadows.**
- Font: Inter (Google Fonts) — `AppTypography` in `fluxfoxus/lib/core/theme/app_typography.dart`
- Spacing: 4px base grid — `AppSpacing` in `fluxfoxus/lib/core/theme/app_spacing.dart`
- Radius: `AppRadius` in `fluxfoxus/lib/core/theme/app_radius.dart`

---

## 4. Completed Work (All Committed & Pushed to `origin/ff`)

| Phase / Step | Commit | Details |
|---|---|---|
| Phase 1-A Step 1: Design Tokens & Theme | Prior | `ThemeTokens`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppTheme.darkTheme`, 5 tests passing |
| Phase 1-A Step 2: Database & Storage | `ee261d0` | SQLite 6 tables, Hive 3 boxes, 11 unit tests passing |
| Phase 1-A Step 3: Navigation Shell | `24db347` | go_router, floating pill nav bar, full-screen takeover on /focus/session, ApertureIcon, 10 tests passing |
| Phase 1-A Step 4: Permissions Onboarding | `7c7d54f` | 4-step wizard, PermissionService, PermissionsNotifier, 13 tests passing |
| Phase 1-B Step 5: Preset System | **`7ab48a2`** | **Latest push — details below** |

### Phase 1-B Step 5 (Latest — Commit `7ab48a2`)

**Files Created/Modified:**

```
fluxfoxus/lib/features/presets/
  domain/preset.dart                   # Preset model with SQLite toMap/fromMap
  domain/preset_app_restriction.dart   # AppRestriction model
  domain/youtube_mode.dart             # YouTubeMode enum (studyMode, block, allow)
  data/presets_repository.dart         # SQLite CRUD: getAllPresets, savePreset, updatePreset, deletePreset, seedDefaultPresets
  presentation/presets_provider.dart   # Riverpod: presetsRepositoryProvider, presetsListProvider, currentPresetProvider
  presentation/widgets/emoji_picker_sheet.dart  # Searchable emoji bottom sheet
  presets.dart                         # Barrel export

fluxfoxus/lib/presentation/screens/
  preset_create_screen.dart            # Full creation screen per ui_preset.md

fluxfoxus/lib/core/database/
  app_database.dart                    # Updated with clean formals

fluxfoxus/test/features/presets/
  presets_repository_test.dart         # 5 unit tests for SQLite CRUD

fluxfoxus/test/presentation/screens/
  preset_create_screen_test.dart       # 7 widget tests for all UI interactions

fluxfoxus/test/core/navigation/
  navigation_test.dart                 # Fixed: arrow_back → close_preset_button
```

**Test Status:**
- `presets_repository_test.dart`: 5/5 ✅ passing
- `preset_create_screen_test.dart`: Tests 1-6 ✅ passing. Test 7 ("Successfully saves preset and pops screen when valid") has a **known timeout issue** (described in Section 6 below).

---

## 5. Project File Structure Summary

```
/workspaces/The_Flux/
  fluxfoxus/
    lib/
      core/
        database/
          app_database.dart              # AppDatabase lifecycle manager
          database_tables.dart           # SQL DDL constants
        navigation/
          app_router.dart                # GoRouter with all routes
          app_routes.dart                # AppRoutes constants
          scaffold_with_nav_bar.dart     # Shell scaffold
          floating_bottom_nav_bar.dart   # 5-tab pill nav bar
          navigation.dart                # Barrel export
        permissions/
          app_permission.dart            # AppPermission enum + PermissionDetails
          permission_service.dart        # PermissionService + DefaultPermissionService
          permissions_notifier.dart      # Riverpod notifier
        storage/
          hive_storage_service.dart      # Hive boxes wrapper
        theme/
          theme_tokens.dart              # Rustic Medley tokens
          app_typography.dart            # Inter typography
          app_spacing.dart               # 4px grid
          app_radius.dart                # Corner radii
          app_theme.dart                 # ThemeData (dark only)
          theme.dart                     # Barrel
      features/
        presets/
          domain/preset.dart
          domain/preset_app_restriction.dart
          domain/youtube_mode.dart
          data/presets_repository.dart
          presentation/presets_provider.dart
          presentation/widgets/emoji_picker_sheet.dart
          presets.dart
      presentation/
        screens/
          home_screen.dart
          usage_stats_screen.dart
          focus_start_screen.dart
          focus_session_screen.dart
          planner_screen.dart
          preset_create_screen.dart      # Main work of Step 5
          preset_edit_screen.dart
          channel_whitelist_screen.dart
          app_limits_screen.dart
          onboarding_screens.dart
      main.dart
    test/
      core/
        database/
          app_database_test.dart
        storage/
          hive_storage_service_test.dart
        navigation/
          navigation_test.dart
        permissions/
          permission_service_test.dart
          onboarding_screens_test.dart
        theme/
          theme_tokens_test.dart
      features/
        presets/
          presets_repository_test.dart
      presentation/
        screens/
          preset_create_screen_test.dart
      widget_test.dart
    pubspec.yaml
    android/app/build.gradle.kts        # minSdk=26, targetSdk=34
  ui_mockups/
    active_focus_session.html           # C1 - served port 8085
    home_screen.html                    # C2 - served port 8086
    preset_creation.html                # C1 - ref mockup
    app_limits.html                     # C2 - served port 8088
    planner.html                        # C2 - served port 8089
    usage_stats.html                    # C2 - served port 8090
  prompts_docx/
    C1/GMP_FF_BUILD.md                  # MASTER BUILD PLAN
    FF_PRD_v1.0.md
    FF_TRD_v1.0.md
    ui_preset.md                        # PresetCreateScreen spec
    ui_navigation.md
    ui_home.md
    ui_planner.md
    ui_app_limits.md
    ui_usage_stats.md
    ff_design_override.md               # CRITICAL: Rustic Medley
  agent_worklog.md                      # Multi-agent registry
  progress_tracker.md                   # Phase tracker
  code1.md                              # THIS FILE
  code1.py                              # Automation script
```

---

## 6. Known Bug — Test 7 Timeout (MUST FIX before continuing)

### Bug Description
**Test:** `preset_create_screen_test.dart` → "Successfully saves preset and pops screen when valid"

**Symptom:** Test body **completes successfully** (all debug prints execute, assert passes, preset is found in DB), but Flutter test framework reports a **10-minute timeout**.

**Root Cause (diagnosed):** After `_savePreset()` calls `ref.read(presetsListProvider.notifier).createPreset(...)`, the `PresetsListNotifier.createPreset` method calls `state = AsyncData(...)` which sets a new state on the Riverpod notifier. This triggers a **background async rebuild** of the `PresetsListNotifier.build()` method (i.e. `getAllPresets()` runs again asynchronously). This background micro-task keeps the test zone/isolate alive, causing `pumpAndSettle()` and the test framework to wait indefinitely for async activity to cease.

**Evidence from logs:**
```
>>> TEST 7: Before expect
>>> TEST 7: After expect
>>> TEST 7: finished successfully and unmounted
# But then test still times out at 10 minutes
```

**Fix Required (not yet applied):**
Two approaches to try (in order):

1. **Override `presetsRepositoryProvider` in the test** with a `FakePresetsRepository` that has instant synchronous `savePreset` and `getAllPresets` returning pre-seeded data. This eliminates the real DB calls from the notifier rebuild entirely.

2. **Dispose the ProviderScope** after the assertion using `addTearDown(() => container.dispose())` with a manual `ProviderContainer` instead of the widget-level `ProviderScope`.

**Implementation (preferred fix — approach 1):**

In `preset_create_screen_test.dart`, create `class FakePresetsRepository extends PresetsRepository` that overrides `savePreset` and `getAllPresets` to operate on an in-memory list. Then override `presetsRepositoryProvider` with this fake.

---

## 7. Next Immediate Task (after fixing Test 7)

### Task: Phase 1-B Step 6 — Focus Timer + Foreground Service

**Reference Doc:** `prompts_docx/C1/GMP_FF_BUILD.md` → Phase 1-B Step 6  
**TRD Reference:** TRD Section 8 (Focus Session State Machine)

**What to build:**
1. **`flutter_foreground_task` Foreground Service** — keeps timer alive when app is backgrounded, shows persistent notification with elapsed/remaining time.
2. **3 Timer Modes:**
   - `Countdown` — counts DOWN from preset total duration (e.g. 90m)
   - `Stopwatch` — counts UP indefinitely
   - `Open-Ended` — no duration limit, stops on user action
3. **Timer State Persistence** — Hive `focus_session_state` box. Writes every 5 seconds. Survives app kill.
4. **Flip-Clock Widget** — Mechanical split-line flip card animation for HH:MM:SS per `active_focus_session.html` mockup. Cards in `#13191F` bg, split seam line in `#CA9C68`.
5. **Focus Session State Machine:**
   - States: `idle`, `running`, `paused`, `break`, `completed`
   - `FocusSessionNotifier` Riverpod AsyncNotifier
   - `focusSessionProvider`, `timerStateProvider`, `activePresetProvider`
6. **`FocusSessionScreen`** — Full-screen takeover (nav bar hidden), flip clock, header status (preset name pill + break count), bottom controls (Stop, Break, Pause/Play).
7. **Automated Tests:**
   - `focus_timer_test.dart` — unit tests for timer arithmetic, state transitions
   - `focus_session_screen_test.dart` — widget tests for all controls and state display

**Key File Paths for Step 6:**
```
fluxfoxus/lib/features/focus/
  domain/focus_session.dart
  domain/timer_mode.dart
  domain/session_status.dart
  data/focus_session_repository.dart
  services/foreground_timer_service.dart
  presentation/focus_session_notifier.dart

fluxfoxus/lib/presentation/screens/
  focus_session_screen.dart            # Already scaffolded (update it)

fluxfoxus/lib/presentation/widgets/
  flip_clock.dart                      # New: mechanical flip card widget
  flip_clock_digit.dart                # Single digit flip card

fluxfoxus/test/features/focus/
  focus_timer_test.dart
fluxfoxus/test/presentation/screens/
  focus_session_screen_test.dart
```

---

## 8. Workflow Rules (MUST follow every task)

1. **Always check `agent_worklog.md` before starting a task** — verify no file conflicts with Code2.
2. **Update `agent_worklog.md` and `progress_tracker.md`** at start AND end of every step.
3. **Testing Standard:** Every screen, feature, and field MUST have automated tests. `flutter test` must return 0 failures.
4. **`flutter analyze` must return 0 issues** before committing.
5. **Branch Lock:** ONLY work on `ff` branch. Never commit to `main` or `fd`.
6. **Review Summary Standard:** Every time you present completed work to the user, append a 3-section **Review Summary**:
   - *What exactly the user has to review*
   - *What they are going to review*
   - *What exactly it is*
7. **User Abbreviations:** `nt` = next task | `raupwfiles` = update progress_tracker.md and agent_worklog.md

---

## 9. Multi-Agent Context (Code2)

Code2 is working on separate HTML/CSS UI mockup screens. Code2's files:
- `ui_mockups/usage_stats.html` (port 8090)
- `ui_mockups/planner.html` (port 8089)
- `ui_mockups/home_screen.html` (port 8086)
- `ui_mockups/app_limits.html` (port 8088)

**Do NOT touch Code2's files.** Code1 owns all `fluxfoxus/lib/` Flutter source code.

---

## 10. Git State at Handoff

```
Branch: ff
Latest commit: 7ab48a2
Message: feat(presets): implement presets CRUD repository, creation screen, and automated tests (Phase 1-B Step 5)
Pushed: YES — origin/ff updated
Ahead of origin: 0 commits
Working tree: CLEAN
```

---

## 11. Test Commands

```bash
# Run all tests
cd /workspaces/The_Flux/fluxfoxus
/home/codespace/flutter/bin/flutter test

# Run specific test files
/home/codespace/flutter/bin/flutter test test/features/presets/presets_repository_test.dart
/home/codespace/flutter/bin/flutter test test/presentation/screens/preset_create_screen_test.dart

# Static analysis (must be 0 issues)
/home/codespace/flutter/bin/flutter analyze

# Commit pattern used
git add -A
git commit -m "feat(<scope>): description (Phase X-Y Step N)"
git push origin ff
```

---

## 12. Immediate Action Checklist for New Agent Session

When resuming as Code1:

1. **Read** `agent_worklog.md` to check Code2's current files
2. **Read** this `code1.md` fully
3. **Fix Test 7** in `preset_create_screen_test.dart` (see Section 6 — use FakePresetsRepository approach)
4. **Run** `flutter test` to confirm ALL tests pass (should be 51+ tests, 0 failures)
5. **Update** `progress_tracker.md` — mark Step 5 as ✅ Completed
6. **Update** `agent_worklog.md` — move Code1 to Step 6
7. **Begin** Phase 1-B Step 6: Focus Timer + Foreground Service (see Section 7)
8. **Run** `code1.py` (see below) — it will bootstrap the Step 6 folder structure
