# Code3 Context/Memory Directory — Index

> **Owner:** Code3 (Miscellaneous Tasks & Documentation Agent)
> **Created:** 2026-10-10
> **Rules:**
> - Only Code3 creates/updates files in this directory.
> - Code1 and Code2 do NOT touch these files.
> - If Code1 or Code2 have information to share, they write it to `agent_worklog.md`; Code3 then reads it and updates the relevant context file here.

---

## File Map

| File | What It Covers |
|---|---|
| `00_INDEX.md` | This file — directory map and rules |
| `01_project_overview.md` | What FluxFoxus is, product vision, app family context (FD ↔ FF) |
| `02_design_system.md` | Complete Rustic Medley palette, typography, spacing, radius, rules |
| `03_architecture.md` | Flutter app architecture, state management, dependency tree |
| `04_database_schema.md` | Full SQLite schema (6 tables) + Hive boxes + all column details |
| `05_features_implemented.md` | Every implemented feature: what it does, what files it lives in, test count |
| `06_navigation_and_routing.md` | All GoRouter routes, tab structure, full-screen takeover logic |
| `07_testing_registry.md` | All test files, what each tests, current pass count |
| `08_ui_mockups.md` | All HTML mockup screens, ports, owner, what to verify |
| `09_build_roadmap.md` | Full phase plan (1-A through 1-G), what's done, what's backlog |
| `10_agent_registry.md` | Code1, Code2, Code3 responsibilities, file ownership, coordination rules |
| `11_dependencies.md` | pubspec.yaml breakdown — every package, why it's used |
| `12_git_state.md` | Branch strategy, commit history summary, latest state |

---

## How to Use These Files

When starting a new task:
1. Read `10_agent_registry.md` first — check who owns what.
2. Read the specific context file for the area you're working in.
3. Never re-scan the whole codebase — these files are the single source of truth.
4. After completing a task, update the relevant context files.
