# Workflow

## TDD Strictness
- **Mode:** Moderate – tests are encouraged but not mandatory for every small change.

## Commit Strategy
- **Conventional Commits** (e.g., `feat:`, `fix:`, `chore:`) with task/track identifiers in the message.

## Code Review Policy
- **Required** for all non‑trivial changes (any change affecting core architecture, storage, or accessibility services).

## Verification Checkpoints
- **After each Phase** (as defined in track plan) run full test suite and request user approval before proceeding.
- **After each Task** run relevant unit/integration tests.

## Lifecycle Rules
- Each task follows the Red‑Green‑Refactor cycle when TDD is chosen.
- All changes are committed immediately after a task is marked complete.
