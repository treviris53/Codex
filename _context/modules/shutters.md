# Shutters Module Rules

## Scope
Rules specific to shutters / rollladen / beschattung packages, helpers, templates, scripts, automations, and dashboards.

## Control model
- `packages/shutters/rollladen_time_window.yaml` is the authoritative target-position and day-window layer.
- `packages/shutters/beschattung_templates.yaml` is the authoritative fachliche shading-decision layer.
- `packages/shutters/beschattung_outputs.yaml` is the only output-mapping layer for `input_boolean.beschattung_ost` and `input_boolean.beschattung_west`.
- `packages/shutters/rollladen_scripts.yaml` is execution-only and must not become a second decision layer.

## Integration context
- Shutters are primarily Homematic IP / HmIP based.
- The installed HACS integration `Homematic(IP) Local for OpenCCU` is relevant environment context.
- Weather-related dashboard and visualization work may also depend on installed DWD-related HACS components and weather cards.

## Override model
- `input_boolean.rollladen_override_ost` and `input_boolean.rollladen_override_west` are manual override flags.
- Override detection, timer lifecycle, and startup reconcile must stay consistent.
- Preserve the current documented asymmetry of Nord unless a deliberate redesign is requested.

## Safety paths
- Preserve the explicit Ost door-failsafe behavior unless explicitly requested otherwise.
- Treat plug-window logic and latest-close behavior as operator-visible behavior that must stay documented when changed.

## Documentation
- Before changing shutters / beschattung packages, helpers, templates, scripts, automations, or dashboard flows, read `D:\Codex\_ha_dokumentation\shutter\SHUTTER_APP.md`.
- If shutters runtime behavior, target-position logic, shading logic, override lifecycle, diagnostics, or dashboard entry points change, update the Shutter documentation in `D:\Codex\_ha_dokumentation\shutter\`.
- If the documented flow changes, update `D:\Codex\_ha_dokumentation\shutter\shutter_app_flows.drawio` in the same task.
