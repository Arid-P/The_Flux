# Testing Registry

> **Last Updated:** 2026-10-10
> **Run command:** `/home/codespace/flutter/bin/flutter test`
> **Analyzer:** `/home/codespace/flutter/bin/flutter analyze` → must be 0 issues

---

## Current State: 169/169 unit & widget tests passing + 48 responsive layout assertions = **217 total assertions, 0 lints**

---

## Test File Inventory

### Core — Theme

| File | Tests | What It Tests |
|---|---|---|
| `test/core/theme/theme_tokens_test.dart` | 5 | Colour token values, radius constants, non-null checks |

---

### Core — Database

| File | Tests | What It Tests |
|---|---|---|
| `test/core/database/app_database_test.dart` | Part of 11 | SQLite DB creation, table schema, foreign keys |
| `test/core/storage/hive_storage_service_test.dart` | Part of 11 | Hive box open/close, preference read/write, category/metadata accessors, focus session state read/write |

---

### Core — Navigation

| File | Tests | What It Tests |
|---|---|---|
| `test/core/navigation/navigation_test.dart` | 10 | Route paths, GoRouter shell structure, tab index mapping, nav bar visibility logic |

---

### Core — Permissions

| File | Tests | What It Tests |
|---|---|---|
| `test/core/permissions/permission_service_test.dart` | Part of 13 | `AppPermission` enum, `PermissionDetails` metadata, mock permission service |
| `test/presentation/screens/onboarding_screens_test.dart` | Part of 13 | 4-step wizard flow, screen navigation, progress bar, skip/continue actions |

---

### Features — Presets

| File | Tests | What It Tests |
|---|---|---|
| `test/features/presets/presets_repository_test.dart` | 5 | SQLite CRUD: save, getAll, update, delete, foreign key cascade |
| `test/presentation/screens/preset_create_screen_test.dart` | 7 | Break stepper increments/decrements, emoji picker trigger, YouTube radio selection, save with validation, async teardown fix via `_FakePresetsRepository` |
| `test/presentation/screens/preset_edit_screen_test.dart` | Widget | Loading preset & restrictions from SQLite, interactive edits, deletion flow |

---

### Features — Focus & Streaks

| File | Tests | What It Tests |
|---|---|---|
| `test/features/focus/focus_session_test.dart` | Part of 24 | `FocusSession` model: `remaining`, `progress`, `canTakeBreak`, `copyWith`, serialization/deserialization |
| `test/features/focus/focus_session_notifier_test.dart` | Part of 24 | `FocusSessionNotifier` state machine: start, pause, resume, break, endBreak, stop, complete, auto-complete at countdown end |
| `test/features/focus/break_system_test.dart` | 5 | Break guard (`canTakeBreak`), break count decrement, exhaustion state, haptic calls, auto-expiry |
| `test/features/focus/wait_time_calculator_test.dart` | Part of tests | `WaitTimeCalculator.calculateWaitSeconds()` formula validation, weight lookup table, clamp behavior |
| `test/features/focus/streak_repository_test.dart` | Unit | Streak CRUD, atomic increment, longest streak update, streak dates |
| `test/features/focus/streak_evaluation_service_test.dart` | Unit | Daily evaluation algorithm, neutral days (`min=0`), scaled rules per TRD §5.3.1 |

---

### Features — App Blocking (Accessibility & Platform Bridge)

| File | Tests | What It Tests |
|---|---|---|
| `test/features/blocking/app_detection_service_test.dart` | Platform Mock | Platform channel `com.fluxfoxus/accessibility_service`, package detection |
| `test/features/blocking/session_blocking_enforcer_test.dart` | Unit | Focus session blocking enforcement, preset restrictions, auto-redirect |

---

### Presentation — Widgets

| File | Tests | What It Tests |
|---|---|---|
| `test/presentation/widgets/flip_clock_test.dart` | Part of 24 | FlipClock rendering, digit display, color in focus vs break mode, seam line presence |
| `test/presentation/widgets/stop_focusing_modal_test.dart` | ~8 | Modal display, countdown timer shows, Quit locked during countdown, Keep Going unlocked, unlock at 0 |

---

### Presentation — Screens

| File | Tests | What It Tests |
|---|---|---|
| `test/presentation/screens/focus_session_screen_test.dart` | Part of 24 | Full-screen layout, header pill, FlipClock present, Stop/Pause/Break button states, Break button absence when 0 breaks |
| `test/widget_test.dart` | 1 | Root app smoke test (widget builds without error) |

---

### Responsive Layout

| File | Tests | What It Tests |
|---|---|---|
| `test/responsive_test.dart` | 48 | Layout assertions across 6 viewport profiles: 320×568, 390×844, 640×360, 844×390, 768×1024, 1024×768. Covers all implemented screens. |

---

## Testing Patterns

### Hermetic Widget Tests
Widget tests never use real SQLite or Hive. They use `ProviderScope` with `overrides`:
```dart
ProviderScope(
  overrides: [
    presetsRepositoryProvider.overrideWith((_) => _FakePresetsRepository()),
  ],
  child: const PresetCreateScreen(),
)
```

### Fake Implementations
Each repository and service has a `FakeXxx` class:
- `FakeFocusSessionRepository` — in `focus_session_repository.dart`
- `FakeForegroundTimerService` — in `foreground_timer_service.dart`
- `_FakePresetsRepository` — inline in `preset_create_screen_test.dart`

### Quality Gate (Before Every Commit)
```bash
cd /workspaces/The_Flux/fluxfoxus
/home/codespace/flutter/bin/flutter test         # All tests must pass
/home/codespace/flutter/bin/flutter analyze      # Must be 0 issues
```
