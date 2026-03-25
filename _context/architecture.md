# Architecture Rules

## Scope
General architecture and design rules for Home Assistant modules in this repository.

## Design principles
- Keep strict separation of concerns.
- Avoid hidden dependencies across packages.
- Centralize runtime logic in scripts or clearly owned execution layers.
- Dashboards are for visualization and safe script entrypoints only.

## Standard layers
### Core
- Owns execution, state transitions, locking, and failure handling.
- May interact with real entities and services.

### Scheduler
- Owns time-based triggering and dispatch decisions.
- Must not contain execution logic.

### Helper
- Owns user-editable configuration entities.
- Must not contain runtime logic.

### Dashboard
- Must not directly manipulate hardware entities.
- Should call safe scripts only.
- Should preserve existing operator navigation and subview structure unless a dashboard redesign is explicitly requested.
- Must stay aligned with the authoritative package logic and must not become a second source of runtime decision logic.
- Should prefer clear, compact information architecture with focused subviews over long scrolling pages.
- Should separate control, status, diagnostics, and service/tuning views when that improves operator clarity.
- May intentionally depend on established custom cards when they are part of the productive operator UX; replacing them with native cards is not a default simplification.
- Global Lovelace resource loading changes are architecture-relevant because they can break multiple dashboards at once and therefore require explicit migration planning.

## State management
- Busy lock pattern uses `input_boolean.<module>_busy`.
- Timestamp pattern uses `input_datetime.<module>_busy_since`.
- Only the core layer may set busy state or write busy timestamps.

## Helper rules
- Do not use `initial:` for persistent user-editable helpers.
- Use restore-state behavior for persistent helpers.
- Apply defaults only via bootstrap or explicit migration.

## Validation
Before activating or merging a module change:
- busy lock lifecycle must be correct
- failure paths must clean up state
- restart behavior must remain stable
- helper ownership must stay unambiguous
