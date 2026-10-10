# Project Overview

> **Last Updated:** 2026-10-10
> **Source files:** `prompts_docx/C1/FLUX_CONTEXT.md`, `prompts_docx/FLUXFOXUS/Phase 1/FF_PRD_v1.0.md`, `prompts_docx/C1/GMP_FF_BUILD.md`

---

## The Flux — App Family

The Flux is the umbrella project for two companion Android apps:

| App | Name | Purpose |
|---|---|---|
| **FD** | FluxDone | Task & habit manager — the productivity planner |
| **FF** | FluxFoxus | Focus & app blocking — the execution enforcer |

The two apps are linked via a **MethodChannel IPC bridge** (`com.fluxfoxus/fd_integration`), so that a focus block created in FluxDone can trigger a focus session in FluxFoxus and vice versa.

---

## FluxFoxus (FF) — Core Purpose

FluxFoxus is an Android-only digital focus app. It helps users:
1. **Block distracting apps** during focus sessions using Android's Accessibility Service.
2. **Track screen time** via UsageStats API and categorize apps.
3. **Run timed focus sessions** (countdown, stopwatch, or open-ended) with break management.
4. **Enforce discipline** with friction mechanics (streak system, discipline delay modal).
5. **Study mode for YouTube** — allows only whitelisted channels during a session.

---

## Key Principles

- **Offline-first.** No internet required for any core feature.
- **Android-only.** Phase 1 targets Android only (API 26+, target API 34).
- **Dark-only UI.** The Rustic Medley palette. No light mode in Phase 1.
- **No Blues/Purples.** The original spec used Electric Indigo — this was overridden to the Rustic Medley palette (see `02_design_system.md`).
- **Flat 2D.** Zero elevation, zero shadows on all surfaces.

---

## App Platform Details

| Field | Value |
|---|---|
| Package ID | `com.fluxfoxus` |
| Flutter project dir | `/workspaces/The_Flux/fluxfoxus/` |
| Min Android SDK | API 26 (Android 8.0 Oreo) |
| Target Android SDK | API 34 (Android 14) |
| Flutter version | SDK ^3.13.4 |
| Branch | `ff` |
| Repository | `https://github.com/Arid-P/The_Flux` |

---

## FD ↔ FF Integration (IPC Bridge)

| Direction | Trigger | What Happens |
|---|---|---|
| FD → FF | User creates a timed task in FluxDone | FD sends `focusBlockRequest` via MethodChannel → FF creates a pending FocusSession |
| FF → FD | User starts a session from FF Home | FF calls `createTask` on FD → a "Focus Session" task appears in FluxDone's FF section |
| FD → FF | FD task is updated/deleted | FF updates or deletes the corresponding pending session |

**Channel name:** `com.fluxfoxus/fd_integration`
**Graceful degradation:** If FD is not installed, all MethodChannel calls fail silently.

---

## Current Build Status (as of 2026-10-10)

- **Phase 1-A:** Fully complete (Steps 1–4)
- **Phase 1-B:** Steps 5–8 complete (Presets, Focus Timer, Break System, Stop Focusing Modal)
- **Phase 1-C through 1-G:** Not yet started (App Blocking, UsageStats, Planner, Home, Widget, Notifications, IPC)
- **HTML mockups:** All 6 screens designed and served (Code2)
- **Flutter test suite:** 128/128 passing (+ 48 responsive layout tests), 0 lints
