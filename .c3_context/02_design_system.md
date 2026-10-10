# Design System — Rustic Medley

> **Last Updated:** 2026-10-10
> **Source file:** `ff_design_override.md`, `fluxfoxus/lib/core/theme/theme_tokens.dart`
> **Override note:** The original GMP_FF_BUILD spec used Electric Indigo (#6366F1) / Soft Cyan (#22D3EE). These were REPLACED entirely by the Rustic Medley palette. See `ff_design_override.md`.

---

## Colour Tokens — `ThemeTokens` class

**File:** `fluxfoxus/lib/core/theme/theme_tokens.dart`

| Token | Hex | Name | Role |
|---|---|---|---|
| `ThemeTokens.background` | `#13191F` | River Styx | App background — all screens |
| `ThemeTokens.surface` | `#2B2F2E` | Carbon Fibre | Cards, sheets, modals, nav pill |
| `ThemeTokens.surfaceElevated` | `#232726` | Elevated Carbon | Subtle elevation / Distracting category |
| `ThemeTokens.border` | `#594C3D` | Afternoon Tea | All card borders, dividers, outlines |
| `ThemeTokens.accent` | `#906D4B` | Tanned Wood | Break timer, sub-labels, semi-productive |
| `ThemeTokens.primary` | `#CA9C68` | Amber Autumn | Primary actions, active states, flip-clock seam |
| `ThemeTokens.textPrimary` | `#F8FAFC` | Ghost White | Main text, active numerals |
| `ThemeTokens.textMuted` | `#94A3B8` | Muted Slate Grey | Labels, captions, disabled, inactive |
| `ThemeTokens.danger` | `#EF4444` | — | Destructive actions, streak reset warning |
| `ThemeTokens.warning` | `#CA9C68` | — | Same as primary — caution states |
| `ThemeTokens.success` | `#4E7D56` | — | Completed sessions, positive status |

### Category Palette

| Token | Hex | Category |
|---|---|---|
| `ThemeTokens.categoryProductive` | `#4E7D56` | Productive apps |
| `ThemeTokens.categorySemiProductive` | `#906D4B` | Semi-Productive apps |
| `ThemeTokens.categoryDistracting` | `#232726` | Distracting apps |
| `ThemeTokens.categoryOthers` | `#94A3B8` | Others / Neutral |

---

## Non-Negotiable Design Rules

1. **ZERO blues, cyans, or purples.** Never use `#6366F1`, `#22D3EE`, or any blue-family colour.
2. **Flat 2D only.** Zero elevation, zero box shadows (exception: `StopFocusingModal` has a subtle `Colors.black` shadow for depth — approved).
3. **Font: Inter** via Google Fonts — defined in `AppTypography`.
4. **Spacing: 4px base grid** — `AppSpacing`.
5. **Dark-only.** No light mode. `ThemeMode.dark` forced in `main.dart`.

---

## Typography — `AppTypography` class

**File:** `fluxfoxus/lib/core/theme/app_typography.dart`

Scales defined (Inter, Google Fonts):
- `AppTypography.display()` — Large hero numerals (flip clock)
- `AppTypography.heading1()` — Screen titles
- `AppTypography.heading2()` — Section headings / modal titles
- `AppTypography.body()` — Standard body text
- `AppTypography.label()` — Pills, badges, captions
- `AppTypography.button()` — Button labels
- `AppTypography.micro()` — Small captions, metadata

All take `color` and optional `weight` named parameters.

---

## Spacing — `AppSpacing` class

**File:** `fluxfoxus/lib/core/theme/app_spacing.dart`

Base unit = 4px. Named values:
- `AppSpacing.xs` = 4
- `AppSpacing.s` = 8
- `AppSpacing.m` = 12
- `AppSpacing.l` = 16
- `AppSpacing.xl` = 20
- `AppSpacing.xxl` = 24

---

## Radius — `AppRadius` class

**File:** `fluxfoxus/lib/core/theme/app_radius.dart`

- `AppRadius.sm` = 4.0
- `AppRadius.md` = 8.0 (also `ThemeTokens.radiusMd`)
- `AppRadius.card` = 12.0 (also `ThemeTokens.radiusLg`)
- `AppRadius.lg` = 16.0 (also `ThemeTokens.radiusXl`)
- `AppRadius.pill` = 28.0 (also `ThemeTokens.radiusPill`)

---

## HTML Mockup Colour Mapping (Code2)

The same palette, mapped to CSS variables:
- `color_background` = `#13191F`
- `color_surface` = `#2B2F2E`
- `color_surface_elevated` = `#232726`
- `color_border` = `#594C3D`
- `color_accent` = `#906D4B`
- `color_primary` = `#CA9C68`
- `color_text_primary` = `#F8FAFC`
- `color_text_muted` = `#94A3B8`
- `category_productive` = `#4E7D56`
- `category_semi` = `#906D4B`
- `category_distracting` = `#38332B` / `#232726`
- `category_others` = `#64748B` / `#94A3B8`

---

## Responsive Layout Utilities

**File:** `fluxfoxus/lib/core/theme/responsive_layout.dart`

| Class | Purpose |
|---|---|
| `AppBreakpoints` | Static helpers: `isLandscape()`, `isTablet()` (≥600dp), `isNarrow()` (<360dp) |
| `ResponsiveContent` | Constrains child to `maxWidth` (default 600dp), centers on large screens |
| `AdaptiveScrollBody` | Scrollable body that expands to full viewport height when space allows |

Tested against 6 viewport profiles: 320×568, 390×844, 640×360, 844×390, 768×1024, 1024×768.
