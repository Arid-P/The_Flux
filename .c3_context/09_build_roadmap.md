# Build Roadmap

> **Last Updated:** 2026-10-10
> **Source:** `prompts_docx/C1/GMP_FF_BUILD.md`, `progress_tracker.md`

---

## Status Legend
- ✅ **Done** — Implemented, tested, committed
- 🟡 **Partial** — Started but not complete
- ⏳ **Backlog** — Not yet started
- ❌ **Won't Do (Phase 1)** — Explicitly excluded

---

## Phase 1-A: Foundation

| Step | Task | Status | Commit |
|---|---|---|---|
| 1 | Design Tokens & Theme | ✅ Done | Prior |
| 2 | Database (SQLite 6 tables) + Hive (3 boxes) | ✅ Done | `ee261d0` |
| 3 | Navigation Shell (GoRouter + pill nav) | ✅ Done | `24db347` |
| 4 | Permissions Onboarding (4-step wizard) | ✅ Done | `7c7d54f` |
| — | Responsive Layout System | ✅ Done | `2aec977` |

---

## Phase 1-B: Core Focus System

| Step | Task | Status | Commit |
|---|---|---|---|
| 5 | Preset System (CRUD + creation screen) | ✅ Done | `7ab48a2` |
| 6 | Focus Timer + Foreground Service + FlipClock | ✅ Done | `529fbd9` |
| 7 | Break System (countdown, exhaustion, early end) | ✅ Done | `e0e8d02` |
| 8 | Stop Focusing Modal (discipline friction + formula) | ✅ Done | `a162962` (approx) |
| 9 | Focus Session Screen (full UI integration) | 🟡 Partial | Integrated in Steps 6–8 |
| 10 | Streaks (StreakRecord, WorkManager evaluation) | ⏳ Backlog | — |

---

## Phase 1-C: App Blocking

| Step | Task | Status |
|---|---|---|
| 11 | Accessibility Service + App Detection (Kotlin) | ⏳ Backlog |
| 12 | UsageStats Integration (Kotlin MethodChannel) | ⏳ Backlog |
| 13 | App Limits Screen (Blocks Tab — CRUD, turn-off flow) | ⏳ Backlog |
| 14 | 2/5/10/20 Distraction Intervention Window (overlay) | ⏳ Backlog |

---

## Phase 1-D: YouTube Study Mode

| Step | Task | Status |
|---|---|---|
| 15 | YouTube Study Mode (channel whitelist enforcement) | ⏳ Backlog |
| 16 | Channel Whitelist Screen (full UI + sentence friction) | ⏳ Backlog |

---

## Phase 1-E: Tracking + Planner

| Step | Task | Status |
|---|---|---|
| 17 | Usage Stats Screen (fl_chart: area + bar charts) | ⏳ Backlog |
| 18 | Planner Screen (calendar strip + session cards) | ⏳ Backlog |
| 19 | Home Screen (momentum chart + session card) | ⏳ Backlog |

---

## Phase 1-F: Widget + Notifications

| Step | Task | Status |
|---|---|---|
| 20 | Home Screen Widget (donut ring, WorkManager refresh) | ⏳ Backlog |
| 21 | Notifications (channels, alarm, weekly report) | ⏳ Backlog |

---

## Phase 1-G: FD↔FF IPC Bridge

| Step | Task | Status |
|---|---|---|
| 22 | MethodChannel IPC — FF side (receive + send) | ⏳ Backlog |

---

## Future Phases (FluxFoxus Phases 2–4)

These are defined in `prompts_docx/FLUXFOXUS/Phase 2–4/` but not yet scheduled for implementation:

**Phase 2:**
- F1: Uninstall Protection
- F2: Scheduled Sessions
- F3: AI Break Negotiation
- F4: Streak Grace
- F5: Post-Session Reflection

**Phase 3:**
- F1: Focus Score
- F2: Session Templates + Auto-Scheduling
- F3: Lock Screen Session Status
- F4: AI Improvements
- F5: Bug Fixes & Polish

**Phase 4:**
- F1: Focus Score Enhancement
- F2: Pre-Open Friction
- F3: Category Limits
- F4: App Limit Smart Suggestions
- F5i/ii/iii: Multi-Device Sync

---

## What's Explicitly NOT in Phase 1

- iOS or Web targets
- Cloud sync / backup
- Multiplayer / social features
- Built-in focus music
- AI companion / AI-generated insights
- Lock screen widgets
- Notification-based task creation from FF in FD

---

## HTML Mockup Coverage vs Flutter Implementation

| Screen | Mockup (Code2) | Flutter (Code1) |
|---|---|---|
| Home Screen | ✅ Done (port 8086) | ⏳ Backlog (Step 19) |
| Focus Session | ✅ Done (port 8085) | ✅ Done (Steps 6–8) |
| Preset Creation | ✅ Done (port 8087) | ✅ Done (Step 5) |
| App Limits | ✅ Done (port 8088) | ⏳ Backlog (Step 13) |
| Planner | ✅ Done (port 8089) | ⏳ Backlog (Step 18) |
| Usage Stats | ✅ Done (port 8090) | ⏳ Backlog (Step 17) |
