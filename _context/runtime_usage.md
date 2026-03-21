# Runtime Data Usage

## Source
Runtime snapshot is stored in:
- _ha_runtime_snapshot/

Includes:
- .storage/core.entity_registry
- .storage/core.restore_state

## Purpose
These files are used for:
- validating entity existence
- checking helper values (input_text, input_datetime, etc.)
- verifying mappings (program_map vs real entities)

## Strict Rules

- Runtime data is READ-ONLY
- Never modify files in _ha_runtime_snapshot/
- Never deploy these files back to Home Assistant
- Never treat them as source of truth for configuration

## Source of Truth

- YAML in packages/ and dashboards/ = authoritative configuration
- runtime snapshot = observational data only

## Usage Pattern

When validating:
- entity must exist in entity_registry
- helper values may be read from restore_state
- mappings must be verified against runtime entities

Do NOT:
- generate YAML from runtime snapshot
- sync snapshot back to HA
- overwrite config with runtime data