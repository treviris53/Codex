# Heating Module Rules

## Scope
Rules specific to Heating packages, helpers, templates, scripts, automations, scenes, and dashboards.

## Control model
- `sensor.heizung_sollprofil` is the fachliche target decision.
- `script.heizung_profil_anwenden_pkg` is the authoritative automatic execution path.
- `packages/heating/heating_scenes.yaml` is the authoritative runtime scene layer for the 3-profile heating model.

## Integration context
- Heating is primarily Homematic IP / HmIP based.
- The installed HACS integration `Homematic(IP) Local for OpenCCU` is relevant context when assessing dependency assumptions or environment-specific behavior.

## Operating model
- Keep the intentionally slow / hysteresis-based operating model intact unless explicitly requested.
- `04:03` remains the main daily application point; `00:01` is the midnight re-apply path.
- Immediate applications stay limited to the documented special cases unless a deliberate behavioral change is requested.

## Override model
- `input_boolean.heizung_override` is the manual override flag.
- `timer.heizung_override` represents the temporary override window.
- Manual override detection and timer lifecycle must remain consistent across restart and failure scenarios.

## Documentation
- Before changing Heating packages, helpers, templates, scripts, automations, scenes, or dashboard flows, read `D:\Codex\_ha_dokumentation\heating\HEATING_APP.md`.
- If Heating runtime behavior, profile logic, scene application, override lifecycle, diagnostics, or dashboard entry points change, update the Heating documentation in `D:\Codex\_ha_dokumentation\heating\`.
- If the documented flow changes, update `D:\Codex\_ha_dokumentation\heating\heating_app_flows.drawio` in the same task.
