# Instruction Map

## Zweck

Diese Datei ist die kompakte Landkarte fuer das Regelwerk in diesem Repository.
Sie beantwortet zwei Fragen:

1. Welche Datei regelt was?
2. Welche Datei sollte vor welcher Art von Aufgabe gelesen werden?

## Schnelle Reihenfolge

### Vor jeder inhaltlichen Aenderung

1. `D:\Codex\AGENTS.md`
2. `D:\Codex\_context\project_rules.md`

### Zusaetzlich nach Aufgabenart

| Aufgabentyp | Zusaetzlich lesen |
| --- | --- |
| Architektur, Packages, Scripts, Automationen, Dashboards | `D:\Codex\_context\architecture.md` |
| Dashboard-Redesign, Dashboard-Bugfix, UI-/Subview-Struktur | `D:\Codex\_context\dashboard.md` |
| Deployment, Diff, Reload, Restart, Healthcheck | `D:\Codex\_context\deployment.md` |
| HACS-Abhaengigkeiten, Custom Cards, Custom Integrations, Themes | `D:\Codex\_context\hacs_inventory.md` |
| Runtime-Snapshot, Debug-Snapshots, lokale HA-Analyse | `D:\Codex\_context\runtime_usage.md` |
| Scheduler-Mappings, Helper-Defaults, Dashboard-/Programmkonsistenz | `D:\Codex\_context\lessons_learned.md` |
| Roborock-Modul | `D:\Codex\_context\modules\roborock.md` und `D:\Codex\_ha_dokumentation\roborock\ROBOROCK_APP.md` |
| Heating-Modul | `D:\Codex\_context\modules\heating.md` und `D:\Codex\_ha_dokumentation\heating\HEATING_APP.md` |
| Shutters / Beschattung | `D:\Codex\_context\modules\shutters.md` und `D:\Codex\_ha_dokumentation\shutter\SHUTTER_APP.md` |

## Welche Datei regelt was?

### `D:\Codex\AGENTS.md`

Die globale Arbeitsgrundlage fuer neue Threads:

- Repository- und Runtime-Pfade
- Package-Loading-Annahme
- Laufzeit- und Shell-Kontext
- produktionsnaher Aenderungsmodus
- Dokumentationspflicht
- Dashboard-Grundregeln
- Root-vs-Packages-Regel

Verwendung:
- Immer lesen
- Bei Konflikten hat diese Datei Vorrang vor `_context`

### `D:\Codex\README_AGENT.md`

Die sehr kurze Schnellreferenz:

- Kernregeln
- Environment Summary

Verwendung:
- Gut als schneller Wiedereinstieg
- Kein Ersatz fuer `AGENTS.md`

### `D:\Codex\_context\project_rules.md`

Repository-weite Umsetzungsregeln:

- YAML-Qualitaet
- Change-Style
- additive Aenderungen
- Doku-Konsistenz fuer dokumentierte Module

Verwendung:
- Vor praktisch jeder Aenderung

### `D:\Codex\_context\architecture.md`

Architektur- und Schichtregeln:

- Trennung von Core, Scheduler, Helper, Dashboard
- Dashboard darf keine zweite Entscheidungslogik werden
- kompakte Dashboard-Struktur mit Subviews
- Validierungsprinzipien fuer State-Management

Verwendung:
- Vor Architektur-, Package-, Script-, Automation- und Dashboard-Aenderungen

### `D:\Codex\_context\dashboard.md`

Dashboard-spezifische UX- und Strukturregeln:

- kompakte Seiten
- Subviews / Untermenues
- Trennung von Bedienung, Status, Diagnose und Service
- dashboard-relevante HACS-Bausteine

Verwendung:
- Vor Dashboard-Redesigns, Dashboard-Bugfixes und groesseren UI-Umbauten

### `D:\Codex\_context\hacs_inventory.md`

Inventar der relevanten HACS-Erweiterungen:

- produktiv genutzte Custom Integrations
- dashboard-relevante Custom Cards
- theme- und modulrelevante HACS-Abhaengigkeiten

Verwendung:
- Wenn HACS-Karten, HACS-Integrationen, Themes oder modulrelevante Custom-Komponenten betroffen sind

### `D:\Codex\_context\deployment.md`

Live- und Deploy-Kontext:

- `W:\` entspricht `/config`
- Repo ist autoritative Schreibquelle
- Deployment-Skript und Deploy-Reihenfolge
- Reload-vs-Restart-Hinweise
- Validierungs- und Aktivierungsmatrix

Verwendung:
- Vor Deployments
- Vor produktionsnaher Aenderung mit Aktivierungsfrage

### `D:\Codex\_context\runtime_usage.md`

Regeln fuer Runtime-Snapshots und Offline-Analyse.

Verwendung:
- Wenn `_ha_runtime_snapshot/` oder Runtime-Daten verwendet werden

### `D:\Codex\_context\lessons_learned.md`

Bekannte Fehlerbilder und Schutzregeln:

- Alias-Mapping
- persistente Helper
- Dashboard-Konsistenz

Verwendung:
- Vor Aenderungen an Mappings, Defaults, UI-/Logik-Konsistenz

## Modulregeln

### `D:\Codex\_context\modules\roborock.md`

Regelt:

- `program_map` vs `job_map`
- Busy-State
- Migrationsregeln
- Dokumentationspflicht fuer Roborock
- offizielle Integration plus Xiaomi-Map-Card-Kontext

### `D:\Codex\_context\modules\heating.md`

Regelt:

- Sollprofil als fachliche Zielentscheidung
- Szenen als autoritativer Runtime-Pfad
- bewusst traeges Betriebsmodell
- Override-Modell
- Dokumentationspflicht fuer Heating

### `D:\Codex\_context\modules\shutters.md`

Regelt:

- autoritative Zielpositionslogik
- autoritative Beschattungslogik
- Override- und Failsafe-Modell
- dokumentierte Nord-Asymmetrie
- Dokumentationspflicht fuer Shutters

## Dokumentation vs Regeln

### `_context/...`

Enthaelt Arbeitsregeln.

### `_ha_dokumentation/...`

Enthaelt fachliche und technische Modul-Dokumentation fuer Verhalten, Datenfluss,
Dashboard-Struktur und Troubleshooting.

Faustregel:
- `_context` sagt, wie gearbeitet werden soll
- `_ha_dokumentation` sagt, wie das Modul aktuell funktioniert

## Startvorlagen

Wiederverwendbare Thread-Starts liegen unter:

- `D:\Codex\_codex_vorlagen\`

Verwendung:
- Wenn wiederkehrende Aufgabentypen schnell und konsistent gestartet werden sollen

## Regelpflege

Fuer Aenderungen an Regeldateien verwenden:

- `D:\Codex\_context\rule_change_checklist.md`

Verwendung:
- Wenn `AGENTS.md`, `README_AGENT.md` oder Dateien unter `_context/` geaendert werden
- um angrenzende Dateien gegenzupruefen und Widersprueche zu vermeiden

## Wartungsregel fuer das Regelwerk

Wenn eine Regel geaendert wird, sollten angrenzende Dateien kurz gegengeprueft werden,
damit keine widerspruechlichen Aussagen zwischen `AGENTS.md`, `_context` und
`_ha_dokumentation` stehen bleiben.
