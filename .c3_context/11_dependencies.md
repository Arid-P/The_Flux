# Dependencies

> **Last Updated:** 2026-10-10
> **Source:** `fluxfoxus/pubspec.yaml`
> **Flutter SDK constraint:** `^3.13.4`

---

## Production Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^3.4.3 | State management — all Notifiers and Providers |
| `riverpod_annotation` | ^4.0.7 | Code-gen annotations for Riverpod (used in some providers) |
| `sqflite` | ^2.4.4 | SQLite persistence — sessions, presets, app limits, streaks, channels |
| `hive` | ^2.2.3 | Key-value storage — preferences, app categories, focus session state |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration (box opening, path init) |
| `fl_chart` | ^1.2.0 | Charts — stacked area (usage), stacked bar (daily/weekly) |
| `home_widget` | ^0.10.0 | Android home screen widget (Phase 1-F Step 20) |
| `workmanager` | ^0.10.10 | Background task scheduling (streak eval, widget refresh) |
| `flutter_foreground_task` | ^11.0.3 | Foreground service for focus timer persistence |
| `flutter_secure_storage` | ^11.2.0 | Secure key storage (future use / auth tokens) |
| `go_router` | ^18.0.1 | Declarative navigation routing |
| `flutter_local_notifications` | ^22.3.1 | All notification delivery (session alerts, weekly report) |
| `android_alarm_manager_plus` | ^5.1.1 | 15-min pre-session heads-up notification scheduling |
| `google_fonts` | ^8.2.1 | Inter font (all typography in the app) |
| `flutter_svg` | ^2.3.0 | SVG rendering (future assets/icons) |
| `permission_handler` | ^13.0.2 | Runtime permission requests (POST_NOTIFICATIONS etc.) |
| `rxdart` | ^0.28.0 | Event bus for cross-module communication |
| `uuid` | ^4.6.0 | UUID v4 generation for session/preset IDs |
| `intl` | ^0.20.3 | Date/time formatting |
| `path_provider` | ^2.1.6 | Platform-specific file paths (Hive storage dir) |
| `path` | ^1.9.1 | Path manipulation utilities |

---

## Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | sdk | Flutter test framework |
| `flutter_lints` | ^6.0.0 | Recommended lint rules (`flutter analyze`) |
| `mocktail` | ^1.0.5 | Mock/stub generation for unit tests |
| `build_runner` | ^2.16.1 | Code generation runner |
| `riverpod_generator` | ^4.0.9 | Riverpod code generation |
| `sqflite_common_ffi` | ^2.4.3 | SQLite FFI for unit tests (non-Flutter test environment) |

---

## Packages NOT Yet Used (Installed for Future Steps)

| Package | Used By (Planned) |
|---|---|
| `fl_chart` | Usage Stats Screen (Step 17), Home Screen (Step 19) |
| `home_widget` | Home Screen Widget (Step 20) |
| `workmanager` | Streak evaluation (Step 10), Widget refresh (Step 20) |
| `android_alarm_manager_plus` | Pre-session notifications (Step 21) |
| `flutter_local_notifications` | All notifications (Step 21) |
| `rxdart` | Cross-module event bus |
| `flutter_secure_storage` | Future auth |
| `riverpod_annotation` / `build_runner` / `riverpod_generator` | Not yet using code-gen pattern, manual providers used |

---

## Android SDK Configuration

| Setting | Value |
|---|---|
| `minSdkVersion` | 26 (Android 8.0 Oreo) |
| `targetSdkVersion` | 34 (Android 14) |
| File | `android/app/build.gradle.kts` |
