# Agent Registry & Coordination Rules

> **Last Updated:** 2026-10-10
> **Live registry:** `agent_worklog.md` (check this before every task)

---

## Agent Summary

| Agent | Role | Scope | Branch Lock |
|---|---|---|---|
| **Code1** | Lead UI Designer / Flutter Implementation | `fluxfoxus/lib/` Flutter source code | `ff` only |
| **Code2** | Companion UI Designer / HTML Mockups | `ui_mockups/` HTML/Tailwind prototypes | `ff` only |
| **Code3** | Miscellaneous Tasks & Documentation | `.c3_context/`, `README.md`, cross-project tasks | `ff` only |

---

## File Ownership Map

### Code1 Exclusive Files (DO NOT TOUCH)
- All Flutter source: `fluxfoxus/lib/` (except as noted below)
- Specifically: `fluxfoxus/lib/features/focus/`, `fluxfoxus/lib/presentation/widgets/flip_clock.dart`, `fluxfoxus/lib/presentation/widgets/stop_focusing_modal.dart`, `fluxfoxus/lib/presentation/screens/focus_session_screen.dart`
- `fluxfoxus/test/` test files

### Code2 Exclusive Files (DO NOT TOUCH)
- `ui_mockups/home_screen.html`
- `ui_mockups/app_limits.html`
- `ui_mockups/planner.html`
- `ui_mockups/usage_stats.html`
- `ui_mockups/index.html`
- `fluxfoxus/lib/core/theme/responsive_layout.dart` (claimed by Code2)
- `fluxfoxus/test/responsive_test.dart` (claimed by Code2)

### Shared Files (Collaborative — all agents can update)
- `agent_worklog.md` — update at task start and end
- `progress_tracker.md` — update at task start and end

### Code3 Exclusive Files (Code1/Code2 do NOT touch)
- `.c3_context/` — entire directory
- `README.md` — project documentation
- `code3.md` — Code3 persona file

---

## Information Flow Between Agents

```
Code1 ──writes──► agent_worklog.md ◄── Code2
                        │
                        ▼
                     Code3 reads and
                  updates .c3_context/
```

- Code1 and Code2 NEVER write to `.c3_context/`.
- If Code1 or Code2 need to communicate info to Code3 (e.g., a new feature was added), they add a note to `agent_worklog.md`.
- Code3 reads `agent_worklog.md` before each task and updates context files accordingly.

---

## Mandatory Protocol (All Agents)

1. **Read `agent_worklog.md` before every task.** Confirm no file conflicts.
2. **Register your task** in `agent_worklog.md` when starting.
3. **Update `agent_worklog.md` + `progress_tracker.md`** when done.
4. **Branch invariant:** ALWAYS on `ff`. Never `git checkout main` or `git checkout fd`.
5. **Review Summary rule:** Every completed task presented to user must end with a 3-part Review Summary:
   - What exactly to review
   - What the user is reviewing (screens/files/ports)
   - What exactly it is (spec reference, architectural context)
6. **User abbreviations:**
   - `nt` = next task
   - `raupwfiles` = update `progress_tracker.md` and `agent_worklog.md`

---

## Code3 Coordination Specifics

- Code3 does NOT modify Flutter feature code.
- Code3 does NOT modify HTML mockup files.
- Code3's tasks come directly from the user as ad-hoc requests.
- Before each task, Code3 reads relevant `.c3_context/` file(s) — not the raw source files (unless a deep-dive is needed).
- After completing a task, Code3 updates the relevant context file(s).
