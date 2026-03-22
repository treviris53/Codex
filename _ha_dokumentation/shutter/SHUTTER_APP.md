# Shutter-App in `D:\Codex`

Diese Datei dokumentiert die Shutter-App im Home-Assistant-Workspace. Technisch liegt
sie unter `packages/shutters`, fachlich besteht sie aus Rolladensteuerung, Beschattung,
manuellen Overrides, Debug-Sensoren und Dashboard-Subviews fuer Bedienung und Diagnose.

## Uebersicht

| Baustein | Datei | Hauptzweck |
| --- | --- | --- |
| Rolladen Helper Layer | `packages/shutters/rollladen_helpers.yaml` | UI-nahe Zeitfenster, Offsets, Override-Flags, Timer und Diagnosewerte |
| Autoritative Zielpositionslogik | `packages/shutters/rollladen_time_window.yaml` | Berechnet Open/Close-Zeitfenster und die Zielpositionen fuer Ost, West und Nord |
| Execution Layer | `packages/shutters/rollladen_scripts.yaml` | Setzt Covers auf die berechnete Zielposition |
| Core Automation Layer | `packages/shutters/rollladen_automations_core.yaml` | Wendet Zielpositionen bei Day-Window-, Beschattungs- und Reconcile-Ereignissen an |
| Manual Override Layer | `packages/shutters/rollladen_automations_manual.yaml` | Erkennt manuelle Bedienung und setzt Override-Booleans |
| Override Lifecycle Layer | `packages/shutters/rollladen_automations_override.yaml` | Startet, beendet und reaktiviert Overrides ueber Timer |
| Debug Layer | `packages/shutters/rollladen_debug.yaml` | Stellt Zielposition und Grund als Debug-Sensoren bereit |
| Beschattung Helper Layer | `packages/shutters/beschattung_helpers.yaml` | Parameter fuer Azimut, Elevation, Lux und Temperatur |
| Beschattung Decision Layer | `packages/shutters/beschattung_templates.yaml` | Berechnet die fachliche Beschattungsentscheidung |
| Beschattung Output Layer | `packages/shutters/beschattung_outputs.yaml` | Mappt die Beschattungsentscheidung auf `input_boolean.beschattung_*` |
| Dashboard / UI | `dashboards/sieker_dashboard.yaml`, `dashboards/sieker_hub.yaml`, `dashboards/sieker_hub_v2.yaml` | Bietet Legacy-Subviews sowie die Hub-Varianten v1 und v2 mit Rollladen-Übersicht, Diagnose, Service und Tuning |

## Zweck der App

Die Shutter-App kapselt vier Aufgaben:

1. Berechnung stabiler Oeffnungs- und Schliesszeitfenster relativ zu Sonne und Offsets.
2. Zentrale Ableitung der Zielposition fuer Ost, West und Nord.
3. Fachliche Beschattungsentscheidung auf Basis von Sonne, Licht und Temperatur.
4. Erkennung manueller Bedienung mit temporaerer Pausierung der Automatik fuer Ost und West.

## Architektur

Die aktuelle Architektur ist klar getrennt:

- `beschattung_templates.yaml` trifft die fachliche Beschattungsentscheidung.
- `beschattung_outputs.yaml` bildet diese Entscheidung auf genau einen Output-Boolean ab.
- `rollladen_time_window.yaml` ist die autoritative Zielpositions- und Zeitfenster-Ebene.
- `rollladen_scripts.yaml` liest nur Zielpositionssensoren und trifft selbst keine Fahrentscheidung.
- `rollladen_automations_core.yaml` triggert Apply-Skripte, ohne die Fachlogik zu duplizieren.
- `rollladen_automations_manual.yaml` erkennt nur manuelle Fahrten.
- `rollladen_automations_override.yaml` verwaltet nur die Timer- und Rueckkehrlogik.

## Abhaengigkeiten

### Externe Home-Assistant-Entitaeten

Die App nutzt unter anderem:

- `sun.sun`
- `cover.rollladen_ost`
- `cover.rollladen_west`
- `cover.rollladen_nord`
- `cover.rollladen_all`
- `switch.schalt_mess_steckdose_steckdose`
- `binary_sensor.kuche_balkon_turkontakt`
- `sensor.sun_solar_azimuth`
- `sensor.sun_solar_elevation`
- `sensor.0x00158d008b61ad80_temperature`
- `sensor.balkon_lichtsensor_durchschnittliche_beleuchtungsstarke`
- `sensor.lichtsensor_schlafzimmer_illuminance`
- `sensor.kuche_wandthermostat_temperatur`
- `sensor.fritz_dect_repeater_100_temperatur`

### Paketinterne Abhaengigkeiten

- `binary_sensor.beschattung_ost_aktiv` und `binary_sensor.beschattung_west_aktiv`
  entstehen in `beschattung_templates.yaml`.
- `automation.beschattung_outputs_setzen` setzt daraus `input_boolean.beschattung_ost`
  oder `input_boolean.beschattung_west`.
- `rollladen_time_window.yaml` konsumiert Day-Window, Beschattungs-Outputs, Tuerkontakt
  und Steckdose und berechnet daraus die Zielpositionen.
- `script.rollladen_apply_*` liest diese Zielpositionen und delegiert an `script.rollladen_set_position`.
- Die Core-Automationen rufen nur die Apply-Skripte auf.

## `packages/shutters/rollladen_helpers.yaml`

### Funktion

Diese Datei enthaelt die benutzer- und laufzeitnahen Helper fuer Rolladen-Automatik,
Zeitfenster, Offsets, Override-Zustand und Automatik-Diagnose.

### Wichtige Helper

| Entity | Zweck |
| --- | --- |
| `input_boolean.rollladen_automation_enabled` | Master-Schalter fuer die Automatik |
| `input_boolean.rollladen_override_ost` | Manueller Override fuer Ost |
| `input_boolean.rollladen_override_west` | Manueller Override fuer West |
| `input_boolean.rollladen_boot_guard` | Startschutz nach HA-Start |
| `timer.rollladen_override_ost` | Override-Laufzeit Ost |
| `timer.rollladen_override_west` | Override-Laufzeit West |
| `input_datetime.rollladen_earliest_open` | Frueheste Oeffnung |
| `input_datetime.rollladen_latest_open` | Spaeteste Oeffnung |
| `input_datetime.rollladen_latest_close` | Spaetestes Schliessen |
| `input_datetime.rollladen_ost_plug_open_start` | Start des Ost-Steckdosenfensters |
| `input_datetime.rollladen_ost_plug_open_end` | Ende des Ost-Steckdosenfensters |
| `input_number.rollladen_offset_morgen_min` | Minuten-Offset relativ zum Sonnenaufgang |
| `input_number.rollladen_offset_abend_min` | Minuten-Offset relativ zum Sonnenuntergang |
| `input_datetime.rollladen_last_auto_ost/west/nord` | Zeitstempel letzter Automatikfahrt |
| `input_number.rollladen_last_auto_pos_ost/west/nord` | Letzte Automatik-Zielposition |

## `packages/shutters/beschattung_helpers.yaml`

### Funktion

Diese Datei liefert die parametrierbaren Schwellwerte fuer die fachliche Beschattung.

### Parametergruppen

| Gruppe | Beispiele |
| --- | --- |
| Azimut | `beschattung_azimut_ost_min`, `beschattung_azimut_ost_max`, `beschattung_azimut_west_min`, `beschattung_azimut_west_max` |
| Elevation | `beschattung_elevation_min` |
| Aussentemperatur | `beschattung_sommer_temp_min` |
| Licht | `beschattung_lux_ost_min`, `beschattung_lux_west_min` |
| Raumtemperatur | `beschattung_temp_ost_min`, `beschattung_temp_west_min` |

## `packages/shutters/beschattung_templates.yaml`

### Funktion

Diese Datei trifft die fachliche Beschattungsentscheidung. Sie berechnet Live-Werte,
Abstaende zu Schwellwerten, Freigaben, Richtungspruefungen und die Endzustaende
`binary_sensor.beschattung_ost_aktiv` und `binary_sensor.beschattung_west_aktiv`.

### Entscheidungsstufen

| Stufe | Zweck |
| --- | --- |
| Live-Sensoren | Abbild der aktuellen Umweltwerte |
| Diff-Sensoren | Abstand `Ist - Soll` je Grenzwert |
| Freigaben | Elevation und Sommer-Temperatur als globale Aktivierung |
| Richtungslogik | Azimut-Fenster fuer Ost und West |
| Lokale Bedingungen | Lux und Raumtemperatur je Seite |
| Endzustand | `beschattung_ost_aktiv` bzw. `beschattung_west_aktiv` |

### Ergebnislogik

Ost ist aktiv, wenn gleichzeitig gilt:

- `binary_sensor.beschattung_freigabe = on`
- `binary_sensor.beschattung_azimut_ost = on`
- `binary_sensor.beschattung_lux_ost_ok = on`
- `binary_sensor.beschattung_temp_ost_ok = on`

West ist aktiv, wenn gleichzeitig gilt:

- `binary_sensor.beschattung_freigabe = on`
- `binary_sensor.beschattung_azimut_west = on`
- `binary_sensor.beschattung_lux_west_ok = on`
- `binary_sensor.beschattung_temp_west_ok = on`

### Debug-Ausgaben

- `sensor.beschattung_debug_ost`
- `sensor.beschattung_debug_west`
- diverse `diff_*`-Sensoren
- `blocker`-Attribute an den Aktiv-Sensoren

## `packages/shutters/beschattung_outputs.yaml`

### Funktion

Diese Automation bildet die Beschattungsentscheidung auf die Signalebene ab:

- `input_boolean.beschattung_ost`
- `input_boolean.beschattung_west`

### Ablauf

1. Beschattungs-Aktivsensoren oder HA-Start triggern.
2. Zuerst werden beide Output-Booleans ausgeschaltet.
3. Danach wird, falls vorhanden, genau ein Ziel-Boolean wieder eingeschaltet.

Hinweis: Laut Kommentar ist dies keine Priorisierungslogik, sondern eine Abbildung
aufgrund geometrisch nicht ueberlappender Ost-/West-Sonnenwinkelbereiche.

## `packages/shutters/rollladen_time_window.yaml`

### Funktion

Diese Datei ist die autoritative Zielpositions- und Zeitfenster-Ebene der Shutter-App.
Sie berechnet:

- `sensor.rollladen_open_ts`
- `sensor.rollladen_close_ts`
- `binary_sensor.rollladen_day_window`
- `sensor.rollladen_ost_target_position`
- `sensor.rollladen_west_target_position`
- `sensor.rollladen_nord_target_position`

### Zeitfensterlogik

| Sensor | Logik |
| --- | --- |
| `sensor.rollladen_open_ts` | Sonnenaufgang plus Morgen-Offset, zwischen `earliest_open` und `latest_open` geklemmt |
| `sensor.rollladen_close_ts` | Sonnenuntergang plus Abend-Offset, maximal `latest_close` |
| `binary_sensor.rollladen_day_window` | `on`, wenn `now` zwischen `open_ts` und `close_ts` liegt |

### Zielpositionslogik

#### Ost

Reihenfolge:

1. Wenn Tuerkontakt kritisch ist (`on`, `unknown`, `unavailable`) -> `100` mit Grund `door_failsafe`
2. Wenn Steckdose morgens im konfigurierten Fenster aktiv ist -> `100`
3. Wenn Steckdose abends ausserhalb Day-Window aktiv ist, aber vor `latest_close` -> `100`
4. Wenn nicht Day-Window -> `0`
5. Wenn Beschattung aktiv -> `33`
6. Sonst -> `100`

#### West

1. Wenn nicht Day-Window -> `0`
2. Wenn Beschattung aktiv -> `33`
3. Sonst -> `100`

#### Nord

1. Wenn Day-Window -> `100`
2. Sonst -> `0`

Hinweis: Nord ist bewusst asymmetrisch, ohne Beschattungs- oder manuellen Override-Sonderpfad.

## `packages/shutters/rollladen_scripts.yaml`

### Funktion

Diese Datei ist die Ausfuehrungsebene der Shutter-App.

### Wichtige Skripte

| Skript | Aufgabe |
| --- | --- |
| `script.rollladen_set_position` | Setzt eine Cover-Position und schreibt Automatik-Diagnosewerte |
| `script.rollladen_apply_ost` | Liest `sensor.rollladen_ost_target_position` und wendet sie an |
| `script.rollladen_apply_west` | Liest `sensor.rollladen_west_target_position` und wendet sie an |
| `script.rollladen_apply_nord` | Liest `sensor.rollladen_nord_target_position` und wendet sie an |

### Schutzlogik

Alle Apply-Skripte und `rollladen_set_position` pruefen:

- `input_boolean.rollladen_automation_enabled = on`
- `input_boolean.rollladen_boot_guard = off`

`rollladen_set_position` schreibt vor der Fahrt je Cover:

- `input_datetime.rollladen_last_auto_*`
- `input_number.rollladen_last_auto_pos_*`

## `packages/shutters/rollladen_automations_core.yaml`

### Funktion

Diese Datei ist die operative Core-Schicht. Sie konsumiert vorhandene Signale und
wendet Zielpositionen ueber Skripte an, ohne die Fachlogik selbst neu zu berechnen.

### Wichtige Automationen

| ID | Aufgabe |
| --- | --- |
| `rollladen_boot_guard_startschutz` | Aktiviert den Startschutz fuer 1 Minute nach HA-Start |
| `rollladen_override_startup_reconcile` | Stellt Timer-/Override-Konsistenz nach dem Start wieder her |
| `rollladen_day_window_switch` | Reagiert auf Wechsel des Day-Window |
| `rollladen_ost_evening_override_plug` | Reagiert auf Steckdosen- und Zeitfensterereignisse fuer Ost |
| `rollladen_ost_beschattung` | Reagiert auf Beschattungsoutput fuer Ost |
| `rollladen_west_beschattung` | Reagiert auf Beschattungsoutput fuer West |
| `rollladen_ost_tuerkontakt_failsafe` | Erzwingt Ost-Failsafe bei relevantem Tuerkontaktzustand |
| `rollladen_reconcile_10min_start` | Wendet alle 10 Minuten und bei Start den Sollzustand erneut an |

### Wichtige Regeln

- Ost und West respektieren manuelle Overrides.
- Ost kann trotz Override fuer `door_failsafe` direkt gesetzt werden.
- Nord hat bewusst keinen manuellen Override-Pfad.

## `packages/shutters/rollladen_automations_manual.yaml`

### Funktion

Diese Datei erkennt nur manuelle Fahrten und setzt die Override-Booleans.

### Erkennungslogik

Fuer Ost und West wird ein Override gesetzt, wenn:

- die Automatik aktiv ist
- der Boot-Guard aus ist
- fuer die Seite noch kein Override aktiv ist
- `current_position` sich fuer 5 Sekunden geaendert hat
- die Positionsdifferenz mindestens 2 Prozentpunkte betraegt
- die letzte Automatikfahrt mehr als 90 Sekunden her ist

## `packages/shutters/rollladen_automations_override.yaml`

### Funktion

Diese Datei verwaltet den Override-Lifecycle ueber Timer.

### Ablauf

1. Override-Boolean geht auf `on` -> passender Timer startet.
2. Override-Boolean geht auf `off` -> passender Timer wird gestoppt.
3. `timer.finished` -> Override-Boolean wird ausgeschaltet.
4. Anschliessend wird das passende Apply-Skript erneut aufgerufen.

## `packages/shutters/rollladen_debug.yaml`

### Funktion

Diese Datei stellt Debug-Sensoren bereit, die direkt aus der zentralen
Zielpositionslogik abgeleitet werden.

### Debug-Sensoren

- `sensor.rollladen_ost_debug`
- `sensor.rollladen_west_debug`
- `sensor.rollladen_nord_debug`

Wichtige Attribute:

- `reason`
- `master_enabled`
- `day_window`
- `shade`
- `plug_on`
- `door_state`
- `latest_close`
- `plug_open_start`
- `plug_open_end`

## Dashboard-Einstiege in `dashboards/sieker_dashboard.yaml`, `dashboards/sieker_hub.yaml` und `dashboards/sieker_hub_v2.yaml`

### Funktion

Die Shutter-App besitzt drei Dashboard-Einstiege:

- Legacy in `sieker_dashboard.yaml`
- Hub v1 in `sieker_hub.yaml`
- Hub v2 in `sieker_hub_v2.yaml`

### Legacy-Subviews in `sieker_dashboard.yaml`

- `path: rollladen`
- `path: rollladen-diagnose`
- `path: rollladen-service`
- `path: rollladen-beschattung`

### Hub-Subviews in `sieker_hub.yaml` und `sieker_hub_v2.yaml`

- `path: rollladen`
- `path: rollladen-diagnose`
- `path: rollladen-service`
- `path: rollladen-tuning`

### Inhalte der Legacy-Hauptansicht `rollladen`

| Bereich | Inhalt |
| --- | --- |
| Steuerung | Automatik, Day-Window, Overrides und Navigation |
| Zeit-Offsets | Morgen- und Abend-Offsets |
| Rolllaeden | Direkte Tiles fuer Ost, West, Nord und Alle |
| Einflussfaktoren | Sonne, Steckdose, Beschattung, Tuerkontakt |
| Debug | Ost-, West- und Nord-Debug |

### Inhalte der Legacy-Diagnose-Ansicht `rollladen-diagnose`

| Bereich | Inhalt |
| --- | --- |
| Status | Master, Day-Window, Open/Close-Timestamps |
| Einflussfaktoren | Steckdose, Beschattung, Tuerkontakt |
| Debug-Sensoren | State und Attribute fuer Ost, West und Nord |
| Historie | Zielpositionen und Einflussfaktoren ueber Zeit |

### Inhalte der Legacy-Service-Ansicht `rollladen-service`

| Bereich | Inhalt |
| --- | --- |
| Direkte Bedienung | Tile-Karten fuer Covers |
| Policies | Zeitregeln und Offsets |
| Tools | Manuell ausloesbare Apply-Skripte |

### Inhalte der Legacy-Beschattungs-Ansicht `rollladen-beschattung`

| Bereich | Inhalt |
| --- | --- |
| Parameter | Zentrale Beschattungs-Schwellenwerte |
| Live Werte | Rohsensoren fuer Sonne, Temperatur und Licht |
| Diffs | Abstand zum jeweiligen Schwellwert |
| Debug | Warum Ost/West AN oder AUS ist |
| Outputs | `input_boolean.beschattung_ost/west` |
| Logik | Aktiv-Sensoren und ihre Vorbedingungen |

### Inhalte des Hub-Einstiegs `rollladen`

| Bereich | Inhalt |
| --- | --- |
| Status | Master, Day-Window, Open/Close-Zeiten und Override-Status |
| Zielbild | Zielpositionen und kompakte Debug-Sensoren |
| Untermenues | Navigation nach Diagnose, Service und Tuning |
| Einflussfaktoren | Steckdose, Beschattung und Tuerkontakt |

### Inhalte der Hub-Ansicht `rollladen-diagnose`

| Bereich | Inhalt |
| --- | --- |
| Status | Ueberblick ueber Day-Window, Zeitfenster und Tuerkontakt |
| Debug-Sensoren | Kernattribute fuer Ost, West und Nord |
| Historie | Zielpositionen und Einflussfaktoren ueber 24h |

### Inhalte der Hub-Ansicht `rollladen-service`

| Bereich | Inhalt |
| --- | --- |
| Sichere Skripte | Manuell ausloesbare Apply-Skripte |
| Direkte Bedienung | Bewusst getrennter Service-/Notfallbereich fuer Covers |
| Sammelbedienung | Gemeinsame Steuerung fuer `cover.rollladen_all` |

### Inhalte der Hub-Ansicht `rollladen-tuning`

| Bereich | Inhalt |
| --- | --- |
| Zeitregeln | Automatik-Schalter, Day-Window, Open-/Close-Policies und Offsets |
| Beschattung | Parameter fuer Azimut, Elevation, Lux und Temperatur |
| Diagnosewerte | Live- und Diff-Sensoren fuer die Parametrierung |

## End-to-End-Datenfluss

### Beschattungsentscheidung

1. Sonnen-, Licht- und Temperaturwerte aktualisieren sich.
2. `beschattung_templates.yaml` berechnet Freigaben, Richtungen und Aktiv-Sensoren.
3. `beschattung_outputs.yaml` setzt daraus genau einen Output-Boolean.

### Zielpositionsberechnung

1. Day-Window, Steckdose, Tuerkontakt und Beschattungsoutputs triggern `rollladen_time_window.yaml`.
2. Die Datei berechnet die Zielposition je Himmelsrichtung.
3. Zielposition und `reason` stehen als Sensoren bereit.

### Operative Anwendung

1. Eine Core-Automation feuert.
2. Bei Ost/West wird Override respektiert, ausser im Ost-Failsafe-Pfad.
3. Das passende Apply-Skript liest die Zielposition.
4. `script.rollladen_set_position` setzt die Cover-Position.
5. Diagnose-Helfer und Debug-Sensoren spiegeln das Ergebnis.

### Manueller Eingriff

1. Eine manuelle Fahrt veraendert `current_position`.
2. Die Manual-Automation erkennt dies als Override.
3. Override-Boolean und Timer werden aktiviert.
4. Die Core-Schicht unterdrueckt automatische Re-Applys fuer Ost oder West.
5. Nach Ablauf des Timers wird der Override beendet und die Automatik erneut angewendet.

## Fehlerbehandlung und Troubleshooting

### Typische Fehlerbilder

| Symptom | Wahrscheinliche Ursache | Pruefung |
| --- | --- | --- |
| Keine Fahrten | Master aus oder Boot-Guard aktiv | `input_boolean.rollladen_automation_enabled`, `input_boolean.rollladen_boot_guard` |
| Ost bleibt offen | Tuer-Failsafe oder Steckdosen-Hold greift | `sensor.rollladen_ost_debug` Attribut `reason` |
| Beschattung greift nicht | Schwellenwerte oder Freigabe nicht erfuellt | `sensor.beschattung_debug_ost/west`, Aktiv-Sensoren |
| Automatik reagiert nicht nach manueller Fahrt | Override noch aktiv | `input_boolean.rollladen_override_*`, Timer |
| Nord verhaelt sich anders | Design ist absichtlich asymmetrisch | `sensor.rollladen_nord_target_position` und `reason` pruefen |

### Wichtige Diagnose-Entitaeten

- `binary_sensor.rollladen_day_window`
- `sensor.rollladen_open_ts`
- `sensor.rollladen_close_ts`
- `sensor.rollladen_ost_target_position`
- `sensor.rollladen_west_target_position`
- `sensor.rollladen_nord_target_position`
- `sensor.rollladen_ost_debug`
- `sensor.rollladen_west_debug`
- `sensor.rollladen_nord_debug`
- `input_boolean.rollladen_override_ost`
- `input_boolean.rollladen_override_west`
- `input_boolean.beschattung_ost`
- `input_boolean.beschattung_west`

## Migration Notes

- Die Zielpositionsentscheidung ist zentral in `rollladen_time_window.yaml` konzentriert.
- Beschattungsentscheidungen entstehen ausschliesslich in `beschattung_templates.yaml`.
- Nord bleibt bewusst asymmetrisch: eigenes Apply, aber kein manueller Override-Boolean-Pfad.
- Legacy-/Kompatibilitaets-Defaults fuer das Ost-Steckdosenfenster bleiben dokumentiert bestehen.

## Diagramme

Die bearbeitbaren Flussdiagramme liegen in:

- `shutter_app_flows.drawio`

Die Datei enthaelt drei Seiten:

1. `Gesamtuebersicht`
2. `Zielpositionslogik`
3. `Override-Lifecycle`

## Validierungs-Checkliste

Die Dokumentation wurde gegen den aktuellen Stand aus folgenden Dateien erstellt:

- `D:\Codex\packages\shutters\rollladen_helpers.yaml`
- `D:\Codex\packages\shutters\rollladen_time_window.yaml`
- `D:\Codex\packages\shutters\rollladen_scripts.yaml`
- `D:\Codex\packages\shutters\rollladen_automations_core.yaml`
- `D:\Codex\packages\shutters\rollladen_automations_manual.yaml`
- `D:\Codex\packages\shutters\rollladen_automations_override.yaml`
- `D:\Codex\packages\shutters\rollladen_debug.yaml`
- `D:\Codex\packages\shutters\beschattung_helpers.yaml`
- `D:\Codex\packages\shutters\beschattung_templates.yaml`
- `D:\Codex\packages\shutters\beschattung_outputs.yaml`
- `D:\Codex\dashboards\sieker_dashboard.yaml`
- `D:\Codex\dashboards\sieker_hub.yaml`

### Checkpunkte

- Rolladen-, Beschattungs-, Script-, Automation- und Debug-Layer gelesen
- Autoritative Zielpositionslogik dokumentiert
- Beschattungsentscheidung und Output-Mapping dokumentiert
- Override-Erkennung und Timer-Lifecycle dokumentiert
- Legacy-Dashboard-Subviews `rollladen*` aufgenommen
- Hub-Subviews `rollladen`, `rollladen-diagnose`, `rollladen-service` und `rollladen-tuning` aufgenommen
- draw.io-kompatible Flussdiagramme erzeugt

## Einordnung

Die Shutter-App ist ein mehrschichtiges, bewusst entkoppeltes Modul. Die Fachlogik
fuer Beschattung und Zielposition sitzt in Templates, die operative Cover-Steuerung
in wenigen Apply-Skripten, und manuelle Eingriffe werden fuer Ost und West ueber
einen klar begrenzten Override-Lifecycle respektiert.
