# Roborock Module Rules

## Scope
Rules specific to Roborock packages, helpers, scripts, automations, and dashboards.

## Canonical mapping
- `program_map` is the only source of real Home Assistant button entities.
- `program_id` values are canonical.
- `job_map` is an alias layer for scheduler and UI use only.

## Helper model
- User-editable helper values store job aliases, not raw button entity IDs.
- `input_text` helpers may store CSV job aliases where the module expects them.

## Busy state
- `input_boolean.roborock_busy` is the execution lock.
- `input_datetime.roborock_busy_since` is written only when the lock is acquired.
- Restart and failure handling must preserve lock consistency.

## Migration rules
- Do not use `initial:` on persistent Roborock helpers.
- Apply defaults only via explicit bootstrap or migration logic.
