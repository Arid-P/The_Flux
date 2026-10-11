# FluxFoxus

> **Focus. Block. Streak.**  
> An Android app that enforces deep work by blocking distracting apps, tracking real screen time, and holding you accountable through a streak-based discipline friction system.

---

## Overview

**FluxFoxus** is part of **The Flux** — a dual-app productivity ecosystem:

| App | Purpose | Role |
|---|---|---|
| **FluxDone (FD)** | Task & Habit Manager | Plan and structure your work |
| **FluxFoxus (FF)** | Focus & App Blocker | Enforce and execute your plan |

The two apps communicate via an Android **MethodChannel IPC bridge** (`com.fluxfoxus/fd_integration`). When a focus block is scheduled in FluxDone, FluxFoxus queues the session — and vice versa.

---

## Key Features

### ⏱️ Focus Timer & 3D Mechanical Flip Clock
- **3 Timer Modes:**
  - **Countdown:** Set target duration; counts down to zero and auto-completes.
  - **Stopwatch:** Open-ended timer counting up; user-controlled stop.
  - **Open-Ended:** Continuous focus tracking without target pressure.
- **Mechanical Card-Flip Animation:** Custom 3D perspective rotation around the horizontal X-axis (`Matrix4` perspective transform) simulating physical split-flap flip clocks.
- **Persistence Across App Kills:** Automatic state saving to Hive every 5 seconds; wall-clock delta arithmetic ensures timer accuracy upon relaunch.
- **Foreground Service:** Persistent Android notification with live elapsed time updates.

### 🎛️ Presets & Temporal Scheduling
- **Customizable Templates:** Save reusable focus configurations with custom emojis, titles, and break policies (0–6 breaks, 1–15 minutes each).
- **Temporal Time-Block Scheduling:** Presets can be scheduled into specific daily time slots (e.g., 3:00 PM – 5:00 PM) backed by SQLite persistence.
- **Granular Restrictions:** Per-app block/allow rules across 4 categories (Productive, Semi-Productive, Distracting, Others).
- **YouTube Enforcement Modes:** Choose between **Block**, **Allow**, or **Study Mode**.

### ☕ Structured Break System
- Dedicated break countdown in a warm Tanned Wood color palette.
- Dynamic break allowance indicators (e.g., "Break (2 left)"); disables when exhausted.
- "End Break Early" action replaces Pause during breaks.
- Auto-resumes focus session as soon as the break timer elapses.

### 🛡️ Discipline Friction & Streak Accountability
- **Stop Focusing Friction Modal:** Abandoning a focus session mid-way locks action buttons behind a formula-driven cooldown (15–25 seconds):
  $$\text{Wait Time} = f(\text{Current Streak}, \text{Today's Distracting Usage vs. Average})$$
- **Live Countdown:** Real-time countdown on the "Quit Session" button discourages impulsive interruptions.
- **Streak Evaluation:** Abandoning a session resets the user's active streak to 0. Higher streaks increase friction penalties.

### 🚫 Real-Time App Blocking & Distraction Intervention
- **Accessibility Service:** Real-time package detection via `FluxFoxusAccessibilityService` to intercept and redirect blocked apps during sessions.
- **App Limits (Blocks Tab):** Daily per-app usage quotas with configurable extra time allowances (5, 10, or 15 minutes, capped at 60 minutes).
- **2/5/10/20 Intervention Window:** `SYSTEM_ALERT_WINDOW` overlay providing graduated time extensions or a 1-tap exit before returning to focus.

### 📺 YouTube Study Mode
- Whitelist approved educational channels in SQLite (`study_channels`).
- Accessibility node inspection detects YouTube channel names dynamically.
- Interactive confirmation sentence flow prevents impulsive channel additions.

### 📊 Usage Stats & Native Data Bridge
- **Native Package Manager Integration:** Live bridge queries Android `PackageManager` for human-readable app titles and Base64 icon bitmaps.
- **Bézier Momentum Chart:** 24-hour smooth stacked area curve tracking screen time momentum across all 4 categories.
- **Interactive Stacked Bar Charts:** Daily (7-day window) and Weekly (4-week trend) views with multi-segment stacked bars.
- **Near-Zero Color Rendering:** Custom stacked segments ensure all four category colors render visibly even when usage is low or near zero.
- **Historical Navigation:** Chevron arrow navigation across past 7-day weeks and 4-week periods with state reload.
- **Searchable App Directory:** Filter tracked apps by name or category with duration progress bars.

### 📅 Planner Screen
- 7-day horizontal date selector with day/date pills.
- Session cards reflecting scheduled, active, and completed sessions.
- Sync badges (`↻`) for blocks linked from FluxDone.

### 📱 Android 4×2 Home Widget & Background Sync
- Glancable home screen widget powered by `home_widget` displaying active streak, daily focus time, and quick-start actions.
- Background alarms and maintenance tasks scheduled via `workmanager`.

---

## Design System — Rustic Medley

FluxFoxus strictly adheres to the **Rustic Medley** dark aesthetic: warm, distraction-free earth tones engineered for long-term eye comfort.

### Color Palette

| Token | Hex | Role |
|---|---|---|
| `ThemeTokens.background` | `#13191F` | Deep dark slate app background |
| `ThemeTokens.surface` | `#2B2F2E` | Carbon fibre cards, modals, sheets |
| `ThemeTokens.surfaceElevated` | `#353B3A` | Highlighted surfaces, secondary containers |
| `ThemeTokens.border` | `#594C3D` | Afternoon tea earthy borders |
| `ThemeTokens.primary` | `#CA9C68` | Amber autumn primary actions & active states |
| `ThemeTokens.textPrimary` | `#F8FAFC` | High-contrast ghost white typography |
| `ThemeTokens.textMuted` | `#94A3B8` | Slate grey captions and secondary text |
| `ThemeTokens.categoryProductive` | `#4E7D56` | Earthy foliage green (Productive apps) |
| `ThemeTokens.categorySemiProductive` | `#7A6C44` | Rusty greenish amber (Semi-Productive apps) |
| `ThemeTokens.categoryDistracting` | `#C27838` | Warm high-contrast rust orange (Distracting apps) |
| `ThemeTokens.categoryOthers` | `#94A3B8` | Cool slate grey (Uncategorized / System apps) |

### Design Principles
- **Strictly Flat 2D:** Zero elevation, zero drop shadows. Visual depth is established purely through 1px border lines and distinct container background shades.
- **No Cold Hues:** Absolutely zero blues, cyans, or purples.
- **Typography:** Inter (`google_fonts`) rendered across an accessible hierarchy (`AppTypography`).
- **Layout:** Standardized 4px base grid (`AppSpacing`) and consistent border radii (`AppRadius`).

---

## Architecture & Tech Stack

```
fluxfoxus/
├── android/
│   └── app/src/main/
│       ├── kotlin/com/fluxfoxus/fluxfoxus/
│       │   ├── MainActivity.kt                  # MethodChannel handlers (Accessibility, FD, Usage)
│       │   ├── FluxFoxusAccessibilityService.kt # Window monitoring & package redirection
│       │   └── UsageStatsHelper.kt              # PackageManager & UsageStatsManager queries
│       └── res/mipmap-*/ic_launcher.png         # Custom Rustic Medley aperture launcher icons
└── lib/
    ├── core/
    │   ├── database/       # SQLite database (6 tables) & AppDatabase lifecycle
    │   ├── navigation/     # GoRouter routing, 5-tab floating pill navbar
    │   ├── permissions/    # Permission service & onboarding wizard
    │   ├── storage/        # Hive persistence boxes (preferences, categories, sessions)
    │   └── theme/          # Theme tokens, typography, spacing, responsive utils
    ├── features/
    │   ├── blocking/       # App limits, distraction overlays, YouTube study mode
    │   ├── focus/          # Focus sessions, break system, streaks, foreground service
    │   ├── presets/        # Preset CRUD & preset repositories
    │   ├── usage_stats/    # Native usage bridge, categories, providers
    │   └── widget/         # Home screen widget communication
    └── presentation/
        ├── screens/        # Home, Focus, Presets, Limits, Usage Stats, Planner, Onboarding
        └── widgets/        # Mechanical FlipClock, BezierMomentumChart, StopFocusingModal
```

### Libraries & Dependencies
- **UI Framework:** Flutter 3.x (Dart 3.x) targeting Android
- **State Management:** Riverpod 3.x (`flutter_riverpod`)
- **Navigation:** GoRouter (`go_router`)
- **Storage:** SQLite (`sqflite`), Hive (`hive`, `hive_flutter`), SharedPreferences (`shared_preferences`)
- **Native Android Services:** `flutter_foreground_task`, `workmanager`, `home_widget`
- **Charts:** Custom painted smooth Bézier curves & responsive bar layouts

---

## Implementation Status

### Phase 1: Complete Core Implementation & Polish Pass ✅

| Module | Scope | Status |
|---|---|---|
| **Phase 1-A** | Foundation: Theme Tokens, SQLite (6 tables), Hive (4 boxes), GoRouter Shell, Permissions Onboarding | ✅ Complete |
| **Phase 1-B** | Core Focus System: Presets, Focus Timer, Foreground Service, Flip Clock, Breaks, Stop Modal, Streaks | ✅ Complete |
| **Phase 1-C** | App Blocking: Accessibility Service, App Limits Screen, 2/5/10/20 Intervention Overlay | ✅ Complete |
| **Phase 1-D** | YouTube Study Mode: Whitelist Table, Channel Sniffing, Confirmation Sentence Flow | ✅ Complete |
| **Phase 1-E** | Usage Stats & Planner: 24h Bézier Curve, Daily/Weekly Charts, Searchable Apps, Planner Strip | ✅ Complete |
| **Phase 1-F** | Home Screen Widget & Background Tasks: `home_widget` 4×2 layout, WorkManager tasks | ✅ Complete |
| **Phase 1-G** | FD↔FF IPC Bridge: Bidirectional MethodChannel session synchronization | ✅ Complete |
| **Polish Pass** | Native `PackageManager` app labels & Base64 icons, 3D card-flip animation, time-block scheduling, Rustic Medley contrast refresh, dedicated accessibility routing, production launcher icons | ✅ Complete |

---

## Verification & Quality Assurance

Every feature and regression test is fully automated:

```bash
cd fluxfoxus

# Run static analysis (0 issues required)
/home/codespace/flutter/bin/flutter analyze

# Run complete test suite (Unit, Widget, Navigation, Responsive)
/home/codespace/flutter/bin/flutter test
```

- **Analyzer:** `No issues found! (0 issues)`
- **Test Suite:** **217 / 217 tests passing (100%)**

---

## Installation & Download

The latest release APK can be downloaded directly from GitHub Releases:

### Download via `curl`
```bash
curl -L -o fluxfoxus.apk "https://github.com/Arid-P/The_Flux/releases/download/v0.1.0-preview/app-release.apk"
```

### Install via ADB
```bash
# List connected device IDs
adb devices

# Install to target phone
adb -s <PHONE_ID> install -r fluxfoxus.apk
```

---

## Android Permissions

| Permission | Purpose |
|---|---|
| `PACKAGE_USAGE_STATS` | Read per-app foreground screen time |
| `SYSTEM_ALERT_WINDOW` | Display 2/5/10/20 distraction intervention overlay |
| `FOREGROUND_SERVICE` | Keep focus timer active with a persistent status notification |
| `ACCESSIBILITY_SERVICE` | Real-time detection of foreground applications for blocking |
| `POST_NOTIFICATIONS` | Deliver session completion and reminder notifications (Android 13+) |
| `RECEIVE_BOOT_COMPLETED` | Reschedule alarms and background workers following a device reboot |

---

## Repository & Development Conventions

- **Branch:** `ff` (all active development)
- **Commit Convention:** `feat(scope): description (Phase X-Y Step N)`
- **Design Tokens:** Strict enforcement of the *Rustic Medley* palette in all Flutter screens and widgets.

---

*Built with Flutter · Powered by Rustic Medley · Part of The Flux ecosystem*