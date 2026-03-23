# Runtime Data Usage

## Scope
Rules for using `_ha_runtime_snapshot/` and optional `_ha_debug/` data.

## Purpose
Runtime data may be used for:
- validating entity existence
- reading observed helper values
- verifying mappings against real runtime entities
- debugging restart or state-transition behavior
- inspecting productive logs and traces for read-only diagnosis

## Strict rules
- Runtime data is read-only.
- Never modify files in `_ha_runtime_snapshot/`.
- Never deploy runtime snapshot files back to Home Assistant.
- Never treat runtime data as the source of truth for configuration.
- Never turn a debug-only task into a runtime mutation task implicitly.

## Source of truth
- YAML in `packages/`, `dashboards/`, and maintained config files is authoritative.
- Runtime snapshot is observational only.

## Live production diagnostics
- Productive logs, traces, and runtime state may be inspected when targeted read-only diagnosis is more useful than local partial logs alone.
- Keep production diagnostics tightly scoped to the suspected problem; avoid broad indiscriminate dumps.
- Separate observational steps from corrective steps:
  - diagnosis may read, export, and compare
  - corrective actions must go back through repository change, review, deploy, and activation rules
- During pure diagnosis, do not trigger service calls, reloads, restarts, helper toggles, or direct edits on the runtime mount.
- If productive diagnostics are exported locally, place them under `_ha_debug/` and treat them as disposable analysis artifacts.

## Debug telemetry
- `_ha_debug/` is optional and read-only.
- Prefer targeted captures over large indiscriminate dumps.
- Never convert debug telemetry into configuration.
