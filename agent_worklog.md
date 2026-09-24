# Multi-Agent Coordination Registry (`agent_worklog.md`)

This registry coordinates concurrent/subsequent AI coding agents working in this repository.  
**Rule for all agents:** Before picking up any task or modifying files, check this file. Register your agent name, active scope, and reserved files below. Keep this file updated when starting or finishing work.

---

## 1. Active Agents Registry

| Agent Name | Role / Specialty | Status | Branch | Current Task / Active Scope | Reserved / Active Files | Port(s) Used |
|---|---|---|---|---|---|---|
| **Code1** | Lead UI Designer | **ACTIVE** | `ff` | Generating and serving Active Focus Session UI preview (`ui_focus_session.md` + `ff_design_override.md`). Awaiting UI approval to begin Flutter theme tokens. | `ui_mockups/`, `progress_tracker.md`, `agent_worklog.md` | `8085` |

---

## 2. Agent Details & Active Context

### Agent: `Code1`
* **Assigned Identity:** `Code1`
* **Role:** Lead UI Designer
* **Current Working Branch:** `ff` (Strict branch lock — DO NOT SWITCH BRANCHES)
* **Status:** `ACTIVE` (In-progress)
* **What `Code1` is doing right now:**
  1. Built the static HTML/Tailwind mockup of the **Active Focus Session Screen** (`ui_mockups/active_focus_session.html`) with split-line mechanical flip-clock, bottom controls, and full adherence to the **Rustic Medley** design override (`#13191F`, `#2B2F2E`, `#594C3D`, `#906D4B`, `#CA9C68`, `#F8FAFC`).
  2. Running a local HTTP server on port `8085` to serve the preview.
  3. Tracking overall project milestones in `progress_tracker.md`.
* **Next Steps for `Code1`:**
  - Obtain user approval for the Active Focus Session UI layout.
  - Proceed with Phase 1-A Foundation in Flutter: `fluxfoxus/lib/core/theme/` (ThemeTokens and dark theme implementing Rustic Medley).
* **Exclusive Resources / Do Not Overwrite:**
  - `ui_mockups/active_focus_session.html`
  - `progress_tracker.md` (Update collaboratively; do not wipe)
  - Port `8085` (Local preview server)

---

## 3. Protocol for Other Agents (e.g. `Code2`, `Backend1`, etc.)

1. **Check this Registry:** Read `agent_worklog.md` before claiming or executing any task.
2. **Register Your Agent:** Add a row to the table in Section 1 with your assigned name, role, status (`ACTIVE`), and target scope.
3. **Branch Invariant:** **STAY ON BRANCH `ff`**. Do NOT switch to `main`, `fd`, or any other branch under any circumstances.
4. **Coordinate File Access:** If you are working on the Flutter app backend, SQLite/Hive storage, or other feature specs, make sure not to overwrite files claimed by other active agents.
5. **Update Upon Completion:** When your task is finished, update your status to `IDLE` or `COMPLETED`.
