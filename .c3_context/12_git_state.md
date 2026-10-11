# Git State

> **Last Updated:** 2026-10-10
> **Branch:** `ff` (strict lock — never switch to `main` or `fd`)
> **Remote:** `origin` = `https://github.com/Arid-P/The_Flux`

---

## Active Branch

```
* ff
```

All three agents (Code1, Code2, Code3) work exclusively on `ff`. The user handles all merges back to `main`.

---

## Recent Commit History

| Hash | Message | Author |
|---|---|---|
| `ee0602e` (HEAD, origin/ff) | fix: resolve preset saving failure and replace hardcoded data across screens | Code1 |
| `fece97f` | chore: update conductor track plan with comprehensive review audit | Code1 |
| `a4b08bc` | feat: setup conductor workflow and screen-discipline track | Code1 |
| `f4a81f0` | Created agent Code3. Updated agent workload file and persona file. | Code3 |
| `3896aa4` | docs: update agent_worklog for Code2 responsive completion | Code2 |
| `c3180fa` | feat(ui): implement responsive grid layouts for planner, usage stats, and preset creation | Code2 |
| `e0e8d02` | feat(focus): implement Phase 1-B Step 7 break system, countdown, exhaustion, and tests | Code1 |
| `f26554f` | fix(ui): add no-cache headers and cache-busting to prevent stale iframe content | Code2 |
| `26553fc` | docs: log DOM inspection and responsiveness diagnostics | Code2 |
| `02de985` | docs: update agent_worklog with unified preview port 8080 | Code1 |
| `dba72d5` | feat(ui): adapt HTML mockups to full viewport width with responsive layouts | Code2 |
| `529fbd9` | feat(focus): implement Phase 1-B Step 6 focus timer, foreground service, flip clock, and tests | Code1 |
| `2aec977` | feat(ui): implement automatic responsive scaling across Phase 1-A and Phase 1-B Step 5 | Code1 |
| `bde7594` | fix(ui): enhance color contrast and update weekly horizon to 7 bars in usage stats | Code2 |
| `102dfee` | chore(code1): add agent identity handoff file and bootstrap script | Code1 |
| `7ab48a2` | feat(presets): implement presets CRUD repository, creation screen, and automated tests (Phase 1-B Step 5) | Code1 |
| `c894f98` | docs: add code2.md replication guide and queued task specification | Code2 |
| `cecc4d3` | feat(ui): add Usage Stats screen preview with multi-horizon charts | Code2 |
| `841a9d6` | fix(ui): add seamless redirect & returnUrl linking between planner and preset creation | Code2 |
| `7c7d54f` | feat(permissions): implement 4-step permissions onboarding flow, services, and tests (Phase 1-A Step 4) | Code1 |
| `89a1ee0` | feat(ui): add Planner Screen preview with automated test runner suite | Code2 |
| `24db347` | feat(navigation): implement go_router shell and 5-tab floating pill nav bar (Phase 1-A Step 3) | Code1 |

---

## Commit Naming Convention

```
{type}({scope}): {description} ({Phase X-Y Step N if applicable})
```

Types: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`
Scopes: `focus`, `presets`, `navigation`, `permissions`, `ui`, `database`, `theme`

---

## Working Tree State (at Code3 creation)

```
Branch: ff
HEAD: f4a81f0 (1 commit ahead of origin/ff)
Working tree: Clean
```

---

## Git Commands for Code3

```bash
# Check status
git status
git log --oneline -10

# Add and commit
git add -A
git commit -m "docs(readme): update README.md with comprehensive project overview"
git push origin ff

# Verify branch
git branch   # must show * ff
```

---

## Branch Strategy

| Branch | Purpose | Who Manages |
|---|---|---|
| `ff` | FluxFoxus active development | Code1, Code2, Code3 |
| `main` | Stable release branch | User only |
| `fd` | FluxDone app branch | Not used by any current agent |

The user merges `ff → main` when a milestone is reached, then recreates `ff` from `main`.
