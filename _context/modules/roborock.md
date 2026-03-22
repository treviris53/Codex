# Roborock Module Rules

## Scope
Rules specific to Roborock packages, helpers, scripts, automations, and dashboards.

## Canonical mapping
- `program_map` is the only source of real Home Assistant button entities.
- `program_id` values are canonical.
- `job_map` is an alias layer for scheduler and UI use only.

## Integration context
- Roborock device control is based on the official Home Assistant integration path.
- The dashboard map experience additionally depends on the Xiaomi vacuum map card.
- Treat map-card behavior and vacuum-control behavior as related but not identical layers when documenting or changing the module.

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

## Documentation
- Before changing Roborock packages, scripts, helpers, automations, or dashboard flows, read `D:\Codex\_ha_dokumentation\roborock\ROBOROCK_APP.md`.
- If Roborock runtime behavior, scheduler flow, mappings, diagnostics, or dashboard entry points change, update the Roborock documentation in `D:\Codex\_ha_dokumentation\roborock\`.
- If the documented flow changes, update `D:\Codex\_ha_dokumentation\roborock\roborock_app_flows.drawio` in the same task.
