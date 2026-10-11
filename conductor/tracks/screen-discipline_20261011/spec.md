# Specification: Screen Discipline Feature

**Track ID:** screen-discipline_20261011
**Type:** feature
**Created:** 2026-10-11
**Status:** Draft

## Summary
An offline-first Android productivity and screen discipline app built with Flutter, focused on strict app blocking and time‑blocking via Accessibility Services.

## Context
The project aims to provide high‑intensity learners a distraction‑free environment using mechanical flip‑clock focus sessions, YouTube Study Mode whitelists, and 2/5/10/20 minute intervention overlays.

## User Story
As a high‑intensity learner, I want app‑blocking sessions to enforce screen discipline and improve productivity.

## Acceptance Criteria
- App‑blocking sessions can be started and stopped from the UI.
- Focus timer enforces selectable intervals (2/5/10/20 min) and automatically pauses other apps.
- Accessibility Service correctly overrides other foreground apps during a block.
- Data persistence works offline via SQLite + Hive (no network required).
- UI follows the flat 2D “Rustic Medley” design system with zero‑blue palette.

## Dependencies
- **Flutter UI components** in `fluxfoxus/lib/presentation/*` (widgets, screens).
- **Hive persistence services** in `fluxfoxus/lib/core/storage`.
- **Android Accessibility Service** framework (existing bridge).
- Existing data models in `fluxfoxus/lib/features/*/domain`.
- Navigation utilities in `fluxfoxus/lib/core/navigation`.

## Out of Scope
- Modifying UI components owned by Code 1 or Code 2 without coordination.
- Changing iOS native code.
- Refactoring unrelated modules.

## Technical Considerations
- Follow the Rustic Medley design system palette for any UI widgets.
- Ensure all new code passes `flutter analyze` (0 issues) and `flutter test` (0 failures).
- Use existing Hive adapters; add new adapters if new data models are introduced.
- Maintain branch lock on `ff`; never push to `main`.
- Keep CI pipeline compliance (lint, test, format).

## Deliverables
1. Feature implementation under `fluxfoxus/lib/features/screen_discipline/`.
2. Corresponding unit and widget tests.
3. Documentation updates (`README.md`, changelog).
4. Updated Conductor track definitions.

## Acceptance Criteria (Implementation)
- Feature compiles with no analysis warnings.
- All new tests pass.
- Documentation accurately describes usage.
- Conductor track can be executed via `conductor run screen-discipline_20261011` without errors.
