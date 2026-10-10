# Architecture

> **Last Updated:** 2026-10-10
> **Source files:** `fluxfoxus/lib/`, `pubspec.yaml`, `GMP_FF_BUILD.md`, `FF_TRD_v1.0.md`

---

## High-Level Architecture

```
FluxFoxus Flutter App
│
├── main.dart                        # Entry point: ProviderScope + MaterialApp.router
│
├── core/                            # Cross-feature shared infrastructure
│   ├── database/                    # SQLite via sqflite
│   ├── storage/                     # Hive key-value boxes
│   ├── navigation/                  # GoRouter + nav bar shell
│   ├── permissions/                 # Permission service abstractions
│   └── theme/                       # Design tokens, typography, spacing, responsive
│
├── features/                        # Feature modules (domain-first)
│   ├── presets/                     # Preset CRUD + Riverpod providers
│   └── focus/                       # Focus session domain, services, state notifier
│
└── presentation/                    # App-level screens and shared widgets
    ├── screens/                     # All screen widgets
    └── widgets/                     # Shared reusable widgets (FlipClock, StopFocusingModal)
```

---

## State Management — Riverpod 3.x

Framework: `flutter_riverpod ^3.4.3`

| Provider | Type | What It Does |
|---|---|---|
| `routerProvider` | `Provider<GoRouter>` | GoRouter singleton |
| `appDatabaseProvider` | `Provider<AppDatabase>` | SQLite database lifecycle |
| `hiveStorageServiceProvider` | `Provider<HiveStorageService>` | Hive boxes wrapper |
| `presetsRepositoryProvider` | `Provider<PresetsRepository>` | Preset SQLite CRUD repo |
| `presetsListProvider` | `AsyncNotifierProvider<PresetsListNotifier, List<Preset>>` | Active preset list |
| `currentPresetProvider` | `FutureProvider<Preset?>` | Last-used preset |
| `focusSessionRepositoryProvider` | `Provider<FocusSessionRepository>` | Session persistence repo |
| `foregroundTimerServiceProvider` | `Provider<ForegroundTimerService>` | Foreground service adapter |
| `focusSessionProvider` | `NotifierProvider<FocusSessionNotifier, FocusSession?>` | Active session state machine |

### Architecture Pattern (per feature)

```
domain/     ← Pure Dart models, enums, business logic (no Flutter deps)
data/       ← Repository: SQLite/Hive read-write, Fake impls for testing
presentation/ ← Riverpod Notifiers, Providers, Widget sub-folders
```

---

## Storage Architecture

### SQLite (sqflite)

Used for: persistent structured data that needs querying.

| Table | Purpose |
|---|---|
| `presets` | Focus session templates |
| `preset_app_restrictions` | Per-preset app block/allow rules |
| `focus_sessions` | Completed/abandoned session history |
| `app_limits` | Per-app daily screen time limits |
| `streak_records` | Focus streak tracking |
| `study_channels` | YouTube channel whitelist |

All tables defined as DDL constants in `DatabaseTables` class.
`AppDatabase` class manages the singleton SQLite connection lifecycle.

### Hive (hive_flutter)

Used for: fast key-value data that doesn't need SQL queries.

| Box | Type | Purpose |
|---|---|---|
| `preferences` | `Box` | User settings: min sessions/day, last preset, session confirm threshold |
| `app_categories` | `Box<String>` | Per-app category override (packageName → category) |
| `app_metadata` | `Box<Map>` | Cached app display names/icons |
| `focus_session_state` | `Box` | Active session state (persists across app kill, 5s auto-save) |

---

## Navigation Architecture

Router: `go_router ^18.0.1`

Pattern: `StatefulShellRoute.indexedStack` for 5-tab bottom nav shell. Full-screen routes (focus session, preset create/edit, permissions) are pushed as root navigator routes, hiding the bottom nav.

See `06_navigation_and_routing.md` for the full route map.

---

## Background Services

| Service | Package | Purpose |
|---|---|---|
| Foreground Timer | `flutter_foreground_task ^11.0.3` | Keeps focus session timer running when app is backgrounded. Persistent notification. |
| WorkManager | `workmanager ^0.10.10` | Scheduled background tasks (streak evaluation at 11:59 PM, widget refresh every 15 min) |
| Alarm Manager | `android_alarm_manager_plus ^5.1.1` | 15-min session start heads-up notification |
| Local Notifications | `flutter_local_notifications ^22.3.1` | All notification delivery |

---

## Android Permissions Required

| Permission | Purpose |
|---|---|
| `PACKAGE_USAGE_STATS` | Read per-app screen time |
| `SYSTEM_ALERT_WINDOW` | Overlay window for distraction intervention |
| `FOREGROUND_SERVICE` | Keep timer running in background |
| `ACCESSIBILITY_SERVICE` | Detect foreground app to enforce blocks |
| `RECEIVE_BOOT_COMPLETED` | Re-arm WorkManager on boot |
| `VIBRATE` | Haptic feedback on break transitions |
| `POST_NOTIFICATIONS` | Android 13+ notification permission |

---

## Testing Architecture

All tests are in `fluxfoxus/test/`. The pattern is:
- **Unit tests:** Pure domain/repository logic using `FakeXxx` implementations.
- **Widget tests:** Use `ProviderScope` with overridden fake providers for hermetic testing (no real SQLite/Hive in tests).
- **Responsive tests:** `responsive_test.dart` — 48 assertions across 6 viewport sizes.

Command: `/home/codespace/flutter/bin/flutter test`
Static analysis: `/home/codespace/flutter/bin/flutter analyze` (must be 0 issues before commit)
