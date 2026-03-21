# Runtime Data Usage

## Scope
Rules for using `_ha_runtime_snapshot/` and optional `_ha_debug/` data.

## Purpose
Runtime data may be used for:
- validating entity existence
- reading observed helper values
- verifying mappings against real runtime entities
- debugging restart or state-transition behavior

## Strict rules
- Runtime data is read-only.
- Never modify files in `_ha_runtime_snapshot/`.
- Never deploy runtime snapshot files back to Home Assistant.
- Never treat runtime data as the source of truth for configuration.

## Source of truth
- YAML in `packages/`, `dashboards/`, and maintained config files is authoritative.
- Runtime snapshot is observational only.

## Debug telemetry
- `_ha_debug/` is optional and read-only.
- Prefer targeted captures over large indiscriminate dumps.
- Never convert debug telemetry into configuration.
