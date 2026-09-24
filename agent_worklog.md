# Multi-Agent Coordination Registry (`agent_worklog.md`)

This registry coordinates concurrent/subsequent AI coding agents working in this repository.  
**Rule for all agents:** Before picking up any task or modifying files, check this file. Register your agent name, active scope, and reserved files below. Keep this file updated when starting or finishing work.

---

## 1. Active Agents Registry

| Agent Name | Role / Specialty | Status | Branch | Current Task / Active Scope | Reserved / Active Files | Port(s) Used |
|---|---|---|---|---|---|---|
| **Code1** | Lead UI Designer | **ACTIVE** | `ff` | Phase 1-A Foundation: Dependencies configuration & Flutter Design System / ThemeTokens implementation (`fluxfoxus/lib/core/theme/`) enforcing Rustic Medley palette. | `fluxfoxus/lib/core/theme/`, `fluxfoxus/pubspec.yaml`, `progress_tracker.md`, `agent_worklog.md` | `8085` |

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
* **What `Code1` is doing right now:**
  1. Updating and configuring remaining dependencies in `fluxfoxus/pubspec.yaml` and Android build parameters (`minSdkVersion 26`, `targetSdkVersion 34`).
  2. Implementing the Flutter Design System in `fluxfoxus/lib/core/theme/`:
     - `app_colors.dart` / `theme_tokens.dart` (Rustic Medley: `#13191F`, `#2B2F2E`, `#594C3D`, `#906D4B`, `#CA9C68`, `#F8FAFC`, `#94A3B8`).
     - `app_typography.dart` (Inter typography scales from `type_display` to `type_micro`).
     - `app_spacing.dart` & `app_radius.dart`.
     - `app_theme.dart` (Dark-only `ThemeData`).
* **Next Steps for `Code1`:**
  - Proceed with Step 2 (Database & Hive initialization) and Step 3 (Navigation Shell with `go_router`).
* **Exclusive Resources / Do Not Overwrite:**
  - `fluxfoxus/lib/core/theme/`
  - `fluxfoxus/pubspec.yaml`
  - `progress_tracker.md`
  - `agent_worklog.md`
  - Port `8085` (Preview server remains up)

---

## 3. Protocol for Other Agents (e.g. `Code2`, `Backend1`, etc.)

1. **Check this Registry:** Read `agent_worklog.md` before claiming or executing any task.
2. **Register Your Agent:** Add a row to the table in Section 1 with your assigned name, role, status (`ACTIVE`), and target scope.
3. **Branch Invariant:** **STAY ON BRANCH `ff`**. Do NOT switch to `main`, `fd`, or any other branch under any circumstances.
4. **Coordinate File Access:** If you are working on the Flutter app backend, SQLite/Hive storage, or other feature specs, make sure not to overwrite files claimed by other active agents.
5. **Update Upon Completion:** When your task is finished, update your status to `IDLE` or `COMPLETED`.
