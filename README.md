# FluxFoxus

> **Focus. Block. Streak.**
> An Android app that enforces deep work by blocking distracting apps, tracking screen time, and holding you accountable through a streak-based discipline system.

---

## Overview

**FluxFoxus** is part of **The Flux** — a two-app productivity ecosystem:

| App | Purpose |
|---|---|
| **FluxDone (FD)** | Task & habit manager — plan your work |
| **FluxFoxus (FF)** | Focus & app blocker — execute your plan |

The two apps are linked via an Android **MethodChannel IPC bridge** (`com.fluxfoxus/fd_integration`). When you schedule a focus block in FluxDone, FluxFoxus automatically queues the corresponding session — and vice versa.

---

## Key Features

### ⏱️ Focus Timer
Three timer modes for every work style:
- **Countdown** — Set a target duration; timer counts down to zero and auto-completes.
- **Stopwatch** — Open-ended timer counting up; you decide when to stop.
- **Open-Ended** — Like stopwatch but with no implied end target.

Sessions survive app kill via 5-second Hive auto-save and are restored accurately on relaunch using wall-clock delta arithmetic.

### 🎛️ Presets
Save reusable focus session templates, each with:
- Custom emoji and name
- Break configuration (0–6 breaks, 1–15 minute duration each)
- Per-app block/allow rules across 4 categories (Productive / Semi-Productive / Distracting / Others)
- YouTube mode: **Block**, **Allow**, or **Study Mode** (channel whitelist)

### ☕ Break System
Structured breaks with full state management:
- Break countdown in a distinct Tanned Wood color palette
- Break count shown on button; button greyed out when exhausted
- "End Break Early" replaces Pause during breaks
- Auto-resumes focus session when break timer expires

### 🛡️ Discipline Friction
Stopping a focus session mid-way triggers the **Stop Focusing Modal**:
- Both action buttons are disabled for **15–25 seconds** (formula-driven, not arbitrary)
- Wait time is calculated from your **current streak length** and **today's distracting app usage** vs. your personal daily average
- Live countdown displayed on the "Quit Session" button

### 🔥 Streak System
Daily focus streaks that build accountability:
- Streak resets to 0 when you abandon a session through the discipline friction modal
- Longer streaks increase the weighting of distracting app usage in the wait time formula (the more disciplined you become, the harder it is to quit)

### 🚫 App Blocking *(Phase 1-C — Coming)*
- Block distracting apps during focus sessions via Android Accessibility Service
- App Limits screen: set daily screen time limits per app with per-app streaks
- 2/5/10/20 minute intervention window overlay

### 📊 Usage Stats *(Phase 1-E — Coming)*
- 24-hour stacked area chart (Today)
- 7-day interactive stacked bar chart (Daily)
- Multi-week stacked bar chart + Sunday summary (Weekly)
- Searchable per-app usage breakdown with category pills

### 📅 Planner *(Phase 1-E — Coming)*
- 7-day horizontal calendar strip
- Session cards showing completed / live / scheduled states
- FluxDone-synced sessions show a `↻` badge
- FAB to add new preset sessions

---

## Design System — Rustic Medley

FluxFoxus uses an exclusive dark colour palette called **Rustic Medley** — warm earth tones with zero blues, cyans, or purples.

| Token | Colour | Role |
|---|---|---|
| Background | `#13191F` River Styx | App background |
| Surface | `#2B2F2E` Carbon Fibre | Cards, sheets, modals |
| Border | `#594C3D` Afternoon Tea | All borders |
| Accent | `#906D4B` Tanned Wood | Break timer, secondary actions |
| Primary | `#CA9C68` Amber Autumn | Primary actions, active states |
| Text | `#F8FAFC` Ghost White | Primary text |
| Muted | `#94A3B8` Slate Grey | Secondary text, disabled |

**Design rules:** Flat 2D only — zero elevation, zero shadows. Font: Inter (Google Fonts).

---

## Architecture

### Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart) — Android only (Phase 1) |
| State Management | Riverpod 3.x (`flutter_riverpod ^3.4.3`) |
| Navigation | GoRouter (`go_router ^18.0.1`) |
| Structured Persistence | SQLite via `sqflite ^2.4.4` |
| Key-Value Persistence | Hive (`hive ^2.2.3` + `hive_flutter ^1.1.0`) |
| Background Service | `flutter_foreground_task ^11.0.3` |
| Background Tasks | `workmanager ^0.10.10` |
| Charts | `fl_chart ^1.2.0` |
| Font | `google_fonts ^8.2.1` (Inter) |

### Folder Structure

```
fluxfoxus/
└── lib/
    ├── core/
    │   ├── database/       # SQLite schema (6 tables) & AppDatabase lifecycle
    │   ├── navigation/     # GoRouter routes, 5-tab pill nav bar, ApertureIcon
    │   ├── permissions/    # Permission service abstractions & onboarding
    │   ├── storage/        # Hive boxes (4 boxes) — preferences, categories, session
    │   └── theme/          # ThemeTokens, AppTypography, AppSpacing, AppRadius,
    │                       # AppTheme, ResponsiveLayout utilities
    ├── features/
    │   ├── focus/          # Focus session domain, repository, notifier, services
    │   └── presets/        # Preset domain, repository, Riverpod providers
    └── presentation/
        ├── screens/        # All screen widgets
        └── widgets/        # FlipClock, StopFocusingModal
```

### SQLite Database (6 Tables)

| Table | Purpose |
|---|---|
| `presets` | Focus session templates |
| `preset_app_restrictions` | Per-preset app block/allow rules |
| `focus_sessions` | Historical session log |
| `app_limits` | Per-app daily screen time limits |
| `streak_records` | Focus streak data |
| `study_channels` | YouTube Study Mode channel whitelist |

### Navigation

5-tab floating pill navigation bar:

```
[ Usage · Focus ]  [ Home ]  [ Planner · Block ]
```

Full-screen routes (focus session, preset creation, onboarding) are pushed at root level — the nav bar is automatically hidden.

---

## Implementation Status

### Phase 1-A: Foundation ✅

| Step | What |
|---|---|
| ✅ Step 1 | Design tokens, typography, spacing, dark `ThemeData` |
| ✅ Step 2 | SQLite (6 tables) + Hive (4 boxes) persistence |
| ✅ Step 3 | GoRouter + 5-tab floating pill navigation |
| ✅ Step 4 | 4-step permissions onboarding wizard |
| ✅ Bonus | Responsive layout utilities (6 viewport profiles) |

### Phase 1-B: Core Focus System ✅ (Steps 5–8)

| Step | What |
|---|---|
| ✅ Step 5 | Preset CRUD, creation screen, emoji picker |
| ✅ Step 6 | Focus timer (3 modes), foreground service, mechanical flip clock |
| ✅ Step 7 | Break system (countdown, exhaustion, auto-resume) |
| ✅ Step 8 | Stop Focusing modal (discipline friction, wait formula) |

### Coming Next

| Phase | Focus |
|---|---|
| 1-B Steps 9–10 | Focus session screen polish + streak system |
| 1-C | App blocking via Accessibility Service + Usage Stats API |
| 1-D | YouTube Study Mode enforcement |
| 1-E | Usage Stats screen + Planner screen + Home screen |
| 1-F | Home screen widget + Notifications |
| 1-G | FD↔FF MethodChannel IPC bridge |

---

## UI Mockups

High-fidelity HTML/Tailwind prototypes serve as the visual spec for every screen:

| Screen | Port | Status |
|---|---|---|
| 🏠 Home | 8086 | ✅ Complete |
| ⏱️ Focus Session | 8085 | ✅ Complete |
| 🎛️ Preset Creation | 8087 | ✅ Complete |
| 🚫 App Limits | 8088 | ✅ Complete |
| 📅 Planner | 8089 | ✅ Complete |
| 📊 Usage Stats | 8090 | ✅ Complete |
| 🖥️ Review Hub | 8080 | ✅ Active |

All mockups include embedded automated test runners with assertion gates.

---

## Testing

```bash
cd fluxfoxus

# Run all tests
/home/codespace/flutter/bin/flutter test

# Run responsive layout tests (6 viewport profiles)
/home/codespace/flutter/bin/flutter test test/responsive_test.dart

# Static analysis (must be 0 issues before every commit)
/home/codespace/flutter/bin/flutter analyze
```

**Current test suite:** 128/128 passing + 48 responsive assertions = **0 failures, 0 lints**

---

## Android Permissions

| Permission | Why |
|---|---|
| `PACKAGE_USAGE_STATS` | Read per-app screen time |
| `SYSTEM_ALERT_WINDOW` | Distraction intervention overlay |
| `FOREGROUND_SERVICE` | Keep focus timer alive in background |
| `ACCESSIBILITY_SERVICE` | Detect foreground app for blocking |
| `POST_NOTIFICATIONS` | Notification delivery (Android 13+) |
| `RECEIVE_BOOT_COMPLETED` | Re-arm background tasks after reboot |
| `VIBRATE` | Haptic feedback on break transitions |

---

## Multi-Agent Development

FluxFoxus is built by a coordinated team of AI coding agents:

| Agent | Role |
|---|---|
| **Code1** | Flutter implementation — screens, widgets, state |
| **Code2** | HTML/Tailwind mockups — visual prototypes |
| **Code3** | Documentation, context management, miscellaneous tasks |

Coordination files: `agent_worklog.md` (active task registry), `progress_tracker.md` (phase tracker).

---

## Repository

- **Branch:** `ff` (all active development)
- **Merge to main:** Handled by project lead
- **Commit convention:** `feat(scope): description (Phase X-Y Step N)`

---

*Built with Flutter · Powered by Rustic Medley · Part of The Flux ecosystem*