# Shutter-Dokumentation

Diese Ablage enthaelt die technische Dokumentation der Shutter-App in Home Assistant.
Sie orientiert sich an der bestehenden Struktur unter `D:\Codex\_ha_dokumentation`
und beschreibt den aktuellen Stand aus:

- `packages/shutters/rollladen_helpers.yaml`
- `packages/shutters/rollladen_time_window.yaml`
- `packages/shutters/rollladen_scripts.yaml`
- `packages/shutters/rollladen_automations_core.yaml`
- `packages/shutters/rollladen_automations_manual.yaml`
- `packages/shutters/rollladen_automations_override.yaml`
- `packages/shutters/rollladen_debug.yaml`
- `packages/shutters/beschattung_helpers.yaml`
- `packages/shutters/beschattung_templates.yaml`
- `packages/shutters/beschattung_outputs.yaml`
- `dashboards/sieker_dashboard.yaml`
- `dashboards/sieker_hub.yaml`

## Inhalte

| Datei | Zweck |
| --- | --- |
| `SHUTTER_APP.md` | Hauptdokumentation mit Architektur, Zielpositionslogik, Beschattung, Override-Verhalten, Dashboard und Troubleshooting |
| `shutter_app_flows.drawio` | Bearbeitbare Flussdiagramme fuer Gesamtuebersicht, Zielpositionslogik und Override-Lifecycle |

## Startpunkt

Fuer die fachliche und technische Uebersicht ist `SHUTTER_APP.md` der beste Einstieg.
Die Diagrammdatei `shutter_app_flows.drawio` kann direkt in draw.io / diagrams.net geoeffnet
und spaeter an Architektur- oder Policy-Aenderungen angepasst werden.
