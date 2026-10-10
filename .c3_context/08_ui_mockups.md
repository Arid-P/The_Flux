# UI Mockups

> **Last Updated:** 2026-10-10
> **Owner:** Code2 (all HTML files) + Code1 (active_focus_session.html, preset_creation.html)
> **Directory:** `/workspaces/The_Flux/ui_mockups/`
> **Server script:** `serve_mockups.py`

---

## Screen Registry

| Port | File | Owner | Status | What It Shows |
|---|---|---|---|---|
| 8080 | `index.html` | Code2 | ✅ Active | Unified review hub — viewport simulator with screen switcher + responsive profiles |
| 8085 | `active_focus_session.html` | Code1 | ✅ Complete | Active focus session: mechanical flip clock, stop/pause/break controls, discipline friction modal |
| 8086 | `home_screen.html` | Code2 | ✅ Complete | Home dashboard: 24h Bézier area chart, momentum legend, session card, state switcher |
| 8087 | `preset_creation.html` | Code1 | ✅ Complete | Preset creation: name input, emoji picker, break steppers, app restrictions, YouTube 3-way radio |
| 8088 | `app_limits.html` | Code2 | ✅ Complete | App limits (Blocks tab): CRUD engine, dual-column time picker, Turn-Off streak warning |
| 8089 | `planner.html` | Code2 | ✅ Complete | Planner: 7-day calendar strip, session cards (completed/live/scheduled), FAB |
| 8090 | `usage_stats.html` | Code2 | ✅ Complete | Usage stats: 3-tab (Today/Daily/Weekly), searchable app list, app detail sheet |

---

## Tech Stack (HTML Mockups)

- **HTML5 + Tailwind CSS** (CDN)
- **Vanilla JavaScript** — in-browser state machines, DOM reactivity
- **No build step** — served via `python3 -m http.server`

---

## In-Browser Automated Tests

Every Code2 screen has an embedded `#auto-test-modal` — a floating test runner that executes DOM assertion gates directly in the browser.

| Screen | Assertion Gates | Passing |
|---|---|---|
| `home_screen.html` | 9 | ✅ All |
| `app_limits.html` | (CRUD lifecycle) | ✅ All |
| `planner.html` | 10 | ✅ All |
| `usage_stats.html` | 10 | ✅ All |

External Node.js test scripts:
- `test_code2_screens.js` — runs headless assertions across all 4 Code2 screens
- `test_usage_stats.js` — specific usage stats assertions
- `test_planner_screen.js` — planner-specific assertions
- `test_preset_creation.js` — preset creation assertions

---

## Viewport Simulator (index.html)

The unified review hub at port 8080 supports:

| Profile | Dimensions |
|---|---|
| 📱 Narrow Phone | 320 × 568 |
| 📱 Standard Phone | 390 × 844 |
| 🔄 Landscape Compact | 640 × 360 |
| 🔄 Landscape Standard | 844 × 390 |
| 📱 Tablet Portrait | 768 × 1024 |
| 💻 Tablet Landscape | 1024 × 768 |
| 🖥️ Full Viewport | Dynamic |

All mockups use fluid layout (`max-w-5xl mx-auto`) — no hardcoded mobile pixel dimensions.

---

## Responsive Architecture (Code2 Fix — Commit `dba72d5`)

All mockups were converted from hardcoded narrow containers (`w-[390px] h-[830px]`) to fluid responsive layouts:
- `w-full max-w-5xl mx-auto flex-1`
- Multi-column card grids with `md:grid-cols-2`, `lg:grid-cols-3` Tailwind classes
- Responsive flip-clock orientation for landscape
- Dynamic simulator iframe sizing

---

## What Each Screen Verifies (Key Interactions)

### Active Focus Session (8085)
- Flip clock with Amber seam (`#CA9C68`)
- Break mode: digits shift to Tanned Wood (`#906D4B`)
- Tap **Stop Focusing** → Discipline Friction modal with live countdown
- Pause/Play circle, Break pill

### Home Screen (8086)
- State switcher: Standard / Active Running / 15min Alert / Empty
- 24h stacked area chart, 2×2 legend
- "Start Focusing" primary button

### Preset Creation (8087)
- Emoji picker bottom sheet
- Break steppers (0–6 / 1–15m)
- App category collapsibles + toggle switches
- YouTube radio → Study Mode → Channel Whitelist sheet with sentence friction

### App Limits (8088)
- Add App / Edit App / Delete App DOM updates (in-memory state engine)
- Turn Off flow: streak warning `🔥→🌧️` with 3-second delay
- Dual-column time picker

### Planner (8089)
- 7-day calendar strip with active/today/inactive states
- Session card states: Completed (green border + ✓), Live (amber border + pulse), Scheduled
- FD sync badge `↻` vs native FF badge
- FAB `+ Add Preset` → links to `preset_creation.html?returnUrl=planner.html`

### Usage Stats (8090)
- 3-tab selector (Today/Daily/Weekly)
- Today: Bézier stacked area chart with vivid stroke outlines
- Daily: 7-day interactive bar chart (selected bar full color, others greyscale)
- Weekly: 7-week stacked bar chart + Sunday summary card
- Searchable app list, App Detail bottom sheet
