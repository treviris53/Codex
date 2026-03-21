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
