# Roborock-App in `D:\Codex`

Diese Datei dokumentiert die Roborock-App im Home-Assistant-Workspace. Der Fokus liegt
auf Zweck, Architektur, zentralen Helfern, Skripten, Scheduler-Logik, Dashboard-Einstiegen
und dem End-to-End-Datenfluss zwischen Benutzeroberflaeche, Zeitplan und Roborock-Integration.

## Uebersicht

| Baustein | Datei | Hauptzweck |
| --- | --- | --- |
| Core / Execution Layer | `packages/roborock/roborock_core.yaml` | Verwaltet Busy-Lock, Statusbewertung, Programmausfuehrung, Fehlerbehandlung und manuelle Starts |
| Scheduler / Job Layer | `packages/roborock/roborock_jobs.yaml` | Verwaltet 21 Wochen-Slots, Job-CSV-Helfer, Bootstrap fuer Standardzeiten und Scheduler-Dispatch |
| Dashboard / App-UI | `dashboards/roborock.yaml`, `dashboards/sieker_hub.yaml` | Bietet das bestehende Einzel-Dashboard sowie den integrierten Hub-Einstieg mit Programmen, Karte, Diagnose, Wochenplan und Wartung |

## Zweck der App

Die Roborock-App kapselt drei Aufgaben:

1. Manuelle Ausloesung einzelner Reinigungsprogramme ueber das Dashboard.
2. Geplante Ausfuehrung ueber einen Wochenplan mit 3 Slots pro Tag.
3. Sichere, sequentielle Ausfuehrung von Programmen mit Busy-Lock, Statuspruefungen,
   Timeouts und aufgeraumter Fehlerdiagnose.

## Architektur

Die Implementierung folgt den Projektregeln mit klarer Schichtentrennung:

- Das Dashboard ist nur Einstiegspunkt fuer sichere Skriptaufrufe.
- Der Scheduler entscheidet nur, wann und mit welchen Job-Aliasen gestartet wird.
- Der Core fuehrt Programme aus, setzt Busy-Zustand, bewertet Robot-Status und behandelt Fehler.
- User-editierbare Konfiguration liegt in Helfern (`input_boolean`, `input_datetime`, `input_text`).

## Abhaengigkeiten

### Home-Assistant-Entitaeten ausserhalb der Pakete

Die App setzt voraus, dass die Roborock-Integration folgende Entitaetsklassen bereitstellt:

- `vacuum.saros_20_set`
- Status- und Diagnosesensoren wie:
  - `sensor.saros_20_set_status`
  - `sensor.saros_20_set_batterie`
  - `sensor.saros_20_set_staubsauger_fehler`
  - `sensor.saros_20_set_letzter_reinigungsbeginn`
  - `sensor.saros_20_set_aktueller_raum`
  - `sensor.saros_20_set_reinigungszeit`
- Programmbuttons fuer die einzelnen Zonen- oder Raumprogramme
- Wartungsbuttons fuer Buersten, Filter und Sensoren
- Kartenquelle `image.saros_20_set_map_0_custom` fuer die Map-Card
- Custom Card `custom:xiaomi-vacuum-map-card` im Dashboard

### Paketinterne Abhaengigkeiten

- `roborock_jobs.yaml` nutzt den globalen Scheduler-Schalter aus `roborock_core.yaml`:
  `input_boolean.roborock_schedule_enabled`
- `roborock_jobs.yaml` uebergibt Jobfolgen an `script.roborock_execute_job_chain`
- `script.roborock_execute_job_chain` expandiert Job-Aliase zu Programm-IDs und ruft
  `script.roborock_execute_program_job` auf
- `script.roborock_execute_program_job` drueckt die realen Roborock-Buttons aus `program_map`

Die folgenden Abschnitte beschreiben die drei Kernkomponenten der App im Detail.

## `packages/roborock/roborock_core.yaml`

### Funktion

Das Core-Paket ist die Ausfuehrungsschicht der App. Es stellt Busy-Lock, Diagnose-Helfer,
Ready-/Blocked-Sensoren, Restart-Bereinigung und die eigentliche Programm- bzw. Jobausfuehrung bereit.

### Eingaben

| Eingabe | Typ | Bedeutung |
| --- | --- | --- |
| `program_id` | Script-Feld | Kanonische Programm-ID fuer einen manuellen Einzelstart |
| `program_sequence` | Script-Feld | CSV oder Liste kanonischer Programm-IDs |
| `job_sequence` | Script-Feld | CSV oder Liste von Job-Aliasen |
| `slot_name` | Script-Feld | Slot- oder Diagnosebezeichner |
| `source` | Script-Feld | Quelle des Aufrufs, z. B. `scheduler`, `dashboard`, `manual` |
| `sensor.saros_20_set_status` | Sensor | Bewertet Startbereitschaft, Blockierung und Aktivitaet |
| `sensor.saros_20_set_letzter_reinigungsbeginn` | Sensor | Zusatzerkennung, dass ein Programm wirklich gestartet wurde |

### Wichtige Helfer

| Entity | Zweck |
| --- | --- |
| `input_boolean.roborock_schedule_enabled` | Globaler Hauptschalter fuer den Scheduler |
| `input_boolean.roborock_busy` | Ausfuehrungs-Lock waehrend einer laufenden Programmfolge |
| `input_datetime.roborock_busy_since` | Zeitstempel des Busy-Lock-Erwerbs |
| `input_text.roborock_last_slot` | Letzter ausloesender Slot oder Startkontext |
| `input_text.roborock_last_job` | Letzte Job-Aliasfolge |
| `input_text.roborock_last_program_sequence` | Letzte expandierte Programmfolge |
| `input_text.roborock_current_program` | Aktuell laufendes Programm laut Executor |
| `input_text.roborock_last_error` | Letzte erkannte Fehlersituation |

### Template-Sensoren

| Sensor | Logik |
| --- | --- |
| `binary_sensor.roborock_program_ready` | `on`, wenn Roborock in `idle`, `charging` oder `charging_complete` ist |
| `binary_sensor.roborock_program_blocked` | `on`, wenn der Status z. B. `error`, `locked`, `device_offline`, `mapping` oder `manual_mode` ist |

### Skripte

| Skript | Aufgabe |
| --- | --- |
| `script.roborock_finalize_execution` | Raeumt Busy-Lock und Diagnosezustand auf und schreibt optional Log-/Fehlertext |
| `script.roborock_run_named_program` | Sicherer Dashboard-Einstieg fuer ein einzelnes kanonisches Programm |
| `script.roborock_execute_program_job` | Fuehrt eine Programmfolge sequentiell mit Schutzlogik aus |
| `script.roborock_execute_job_chain` | Expandiert Job-Aliase zu Programmen und startet die Programmausfuehrung |

### Automation

| Automation | Aufgabe |
| --- | --- |
| `id: roborock_busy_reset_on_start` | Setzt Busy-Lock und `roborock_current_program` nach HA-Start mit Verzoegerung zurueck |

Hinweis: Die YAML-ID ist `roborock_busy_reset_on_start`; der Alias lautet
`Roborock Busy Reset bei HA Restart`.

### Kanonische Programm-IDs

`program_map` ist laut Modulregeln die einzige kanonische Abbildung auf echte HA-Buttons.

| Programm-ID | Zielbutton |
| --- | --- |
| `wohn_saug` | `button.saros_20_set_wohn_saugen_2` |
| `wohn_saug_wisch` | `button.saros_20_set_wohn_saug_wisch` |
| `wohn_vac_mop` | `button.saros_20_set_wohn_saugen` |
| `schlaf_saug` | `button.saros_20_set_saugen_schlafzimmer` |
| `schlaf_saug_wisch` | `button.saros_20_set_schlaf_saug_wisch` |
| `schlaf_vac_mop` | `button.saros_20_set_schlaf_vac_mop` |
| `haustier` | `button.saros_20_set_reinigung_von_haustierbedarf` |
| `flur_saug_wisch` | `button.saros_20_set_flur_saug_wisch` |
| `flur_vac_mop` | `button.saros_20_set_flur_vac_mop` |
| `flur_saug` | `button.saros_20_set_flur_saugen` |

### Statusmodell in der Programmausfuehrung

**Ready-States**

- `idle`
- `charging`
- `charging_complete`

**Blocked-States**

- `error`
- `locked`
- `device_offline`
- `charging_problem`
- `manual_mode`
- `remote_control_active`
- `in_call`
- `mapping`
- `updating`
- `shutting_down`
- `unknown`

**Active-States**

- `starting`
- `cleaning`
- `returning_home`
- `docking`
- `going_to_target`
- `zoned_cleaning`
- `segment_cleaning`
- `emptying_the_bin`
- `washing_the_mop`
- `washing_the_mop_2`
- `going_to_wash_the_mop`
- `attaching_the_mop`
- `detaching_the_mop`
- `robot_status_mopping`
- `clean_mop_cleaning`
- `clean_mop_mopping`
- `segment_mopping`
- `segment_clean_mop_cleaning`
- `segment_clean_mop_mopping`
- `zoned_mopping`
- `zoned_clean_mop_cleaning`
- `zoned_clean_mop_mopping`
- `back_to_dock_washing_duster`
- `paused`
- `charger_disconnected`
- `spot_cleaning`

### Interner Ablauf von `script.roborock_execute_program_job`

1. Normalisiert `program_sequence` zu einer Liste von Programm-IDs.
2. Prueft Vorbedingungen:
   - Roboter nicht blockiert
   - Busy-Lock nicht bereits aktiv
   - mindestens ein Programm uebergeben
3. Aktiviert `input_boolean.roborock_busy`.
4. Schreibt `input_datetime.roborock_busy_since` und Diagnose-Helfer.
5. Iteriert ueber jedes Programm:
   - validiert `program_map`
   - wartet auf Ready-State
   - stabilisiert den Ready-State zusaetzlich fuer 20 Sekunden
   - merkt sich `sensor.saros_20_set_letzter_reinigungsbeginn`
   - drueckt den zugeordneten Roborock-Button
   - wartet auf Aktivitaet oder geaenderten Startzeitpunkt
   - wartet anschliessend auf Rueckkehr in einen Ready-State
6. Bei jedem Fehlerpfad wird `script.roborock_finalize_execution` aufgerufen.
7. Nach erfolgreichem Abschluss wird ebenfalls finalisiert und der Busy-Lock freigegeben.

### Ausgaben / Seiteneffekte

- `button.press` auf echte Roborock-Programm-Buttons
- Logbook-Eintraege mit Kontext `source` und `slot_name`
- Aktualisierung der Diagnose-Helfer
- Setzen und Ruecksetzen des Busy-Locks

## `packages/roborock/roborock_jobs.yaml`

### Funktion

Das Jobs-Paket ist die Scheduler- und Konfigurationsschicht. Es modelliert eine feste
Wochenstruktur mit 7 Tagen, 3 Slots je Tag und bis zu 4 Job-Aliasen pro Slot.

### Eingaben

| Eingabe | Typ | Bedeutung |
| --- | --- | --- |
| `input_boolean.roborock_schedule_enabled` | Helper | Aktiviert oder deaktiviert den Wochenplan global |
| `input_boolean.roborock_slot_enabled_<day>_<slot>` | Helper | Aktiviert einen konkreten Wochenslot |
| `input_datetime.roborock_time_<day>_<slot>` | Helper | Uhrzeit eines konkreten Wochenslots |
| `input_text.roborock_jobs_<day>_<slot>` | Helper | CSV-Jobfolge mit max. 4 Aliasen |

### Helfermodell

| Kategorie | Anzahl | Beschreibung |
| --- | --- | --- |
| Slot-Enable-Helper | 21 | Aktiviert/deaktiviert je Wochentag und Slot |
| Slot-Zeit-Helper | 21 | Definiert die Ausloesezeit je Slot |
| Slot-Job-Helper | 21 | Speichert CSV-Job-Aliase je Slot |
| Bootstrap-Flag | 1 | Merkt, ob die einmalige Slot-Zeit-Migration bereits gelaufen ist |

### Job-Alias-Modell

Das Jobs-Paket arbeitet mit Aliasen fuer Scheduler und UI-Kompatibilitaet. Diese werden
im Core auf kanonische Programm-IDs abgebildet.

| Job-Alias | Expandiert zu |
| --- | --- |
| `flur_vm` | `flur_vac_mop` |
| `flur_s` | `flur_saug` |
| `flur_sw` | `flur_saug_wisch` |
| `wohn_sw` | `wohn_saug_wisch` |
| `wohn_vm` | `wohn_vac_mop` |
| `wohn_s` | `wohn_saug` |
| `schlaf_s` | `schlaf_saug` |
| `schlaf_sw` | `schlaf_saug_wisch` |
| `schlaf_vm` | `schlaf_vac_mop` |
| `haustier` | `haustier` |

### Bootstrap-Skript

`script.roborock_slot_time_bootstrap_manual` ist ein einmaliges Migrationswerkzeug fuer
Default-Uhrzeiten, nachdem `initial:` aus den persistenten `input_datetime`-Helfern entfernt wurde.

**Vordefinierte Standardzeiten**

- Slot 1: `08:30:00`
- Slot 2: `09:30:00`
- Slot 3: `10:30:00`

Diese Werte werden fuer alle sieben Wochentage gesetzt und danach mit
`input_boolean.roborock_slot_time_bootstrap_done` als abgeschlossen markiert.

### Scheduler-Automation

Die Automation `roborock_weekday_scheduler` triggert alle 21 Slots ueber `input_datetime`
und validiert danach den echten Wochentag ueber `now().isoweekday()`.

### Interner Ablauf von `roborock_weekday_scheduler`

1. Ein Zeittrigger feuert fuer `mon_1` bis `sun_3`.
2. Der globale Scheduler-Schalter muss `on` sein.
3. Der Busy-Lock muss `off` sein.
4. Die Automation leitet aus `trigger.id` den erwarteten Wochentag ab.
5. Die Automation verifiziert, dass heutiger Kalendertag und Slot-Tag uebereinstimmen.
6. Sie prueft den zugehoerigen Slot-Enable-Helper.
7. Sie liest die CSV-Jobliste des Slots.
8. Sie ruft `script.roborock_execute_job_chain` mit `slot_name`, `source=scheduler`
   und der gelesenen Jobfolge auf.

### Ausgaben / Seiteneffekte

- zeitgesteuerte Aufrufe von `script.roborock_execute_job_chain`
- keine direkte Hardwaresteuerung im Scheduler selbst
- Auswertung und Nutzung der 63 Scheduler-Helfer plus globalem Schalter

## Dashboard-Einstiege in `dashboards/roborock.yaml` und `dashboards/sieker_hub.yaml`

### Funktion

Die Roborock-App besitzt zwei Dashboard-Einstiege:

- `dashboards/roborock.yaml` als bestehendes Einzel-Dashboard
- `dashboards/sieker_hub.yaml` als integrierter Fachmodul-Einstieg im Sieker-Hub

Beide Varianten nutzen ausschliesslich sichere Script-Entrypoints fuer manuelle Programme.

### Aufbau von `dashboards/roborock.yaml`

| Bereich | Inhalt |
| --- | --- |
| Schnellstart / Programme | Buttons fuer einzelne kanonische Programme |
| Diagnose | Status, Batterie, Fehler, Busy, letzte Slot-/Job-/Programmwerte |
| Wartung | Reset-Buttons fuer Buersten, Filter und Sensoren |
| Karte | `xiaomi-vacuum-map-card` mit Status- und Verbrauchs-Tiles |
| Wochenplan | Globaler Scheduler-Schalter plus 7 x 3 Slot-Editoren |

### Aufbau von `dashboards/sieker_hub.yaml`

| Bereich | Inhalt |
| --- | --- |
| `path: roborock` | Verdichteter Top-Level mit Betrieb, letzter Ausfuehrung, Fehlerhinweisen und Navigation |
| `path: roborock-programme` | Vollstaendige Programmauswahl auf Basis kanonischer `program_id` in kompakter Kartenform |
| `path: roborock-karte` | Kartenansicht als eigene Subview |
| `path: roborock-diagnose` | Betriebs-, Verlaufs- und Jobstartdaten als Leseflaeche |
| `path: roborock-wochenplan` | Globaler Scheduler-Schalter, Alias-/ID-Referenz und Wochentagskarten; Tages-Subviews bleiben direkt editierbar |
| `path: roborock-wartung` | Reset-Buttons und Verbrauchsmaterial-Staende in konsistenter Kartensprache |

### Manuelle Programme im Dashboard

Folgende Buttons starten ueber `script.roborock_run_named_program` sichere Einzelprogramme:

- Schlaf saugen
- Schlaf vac+mop
- Flur vac+mop
- Flur saug/wisch
- Wohn saugen
- Wohn saug/wisch
- Haustierbedarf

### Diagnose- und Betriebsdaten im Dashboard

Das Dashboard visualisiert unter anderem:

- `sensor.saros_20_set_status`
- `sensor.saros_20_set_batterie`
- `sensor.saros_20_set_staubsauger_fehler`
- `binary_sensor.roborock_program_ready`
- `binary_sensor.roborock_program_blocked`
- `input_boolean.roborock_busy`
- `input_datetime.roborock_busy_since`
- `input_text.roborock_last_slot`
- `input_text.roborock_last_job`
- `input_text.roborock_last_program_sequence`
- `input_text.roborock_current_program`
- `input_text.roborock_last_error`

Der modernisierte Hub-Einstieg in `dashboards/sieker_hub.yaml` trennt diese
Informationen jetzt bewusst in:

- `Betrieb`
- `Letzte Ausfuehrung`
- `Hinweise`
- `Diagnose`

Die fachliche Funktion bleibt dabei unveraendert; geaendert wurde nur die
operator-orientierte Darstellung.

Die technischen Trace-Felder bleiben im Hub bewusst in der englischen
Benennung (`Last Slot`, `Last Job`, `Last Program Sequence`, `Current Program`),
damit sie direkt zur internen Job- und Programmlogik passen.

## End-to-End-Datenfluss

### Manueller Start aus dem Dashboard

1. Benutzer drueckt einen Programm-Button im Dashboard.
2. `script.roborock_run_named_program` uebergibt eine einzelne kanonische `program_id`.
3. `script.roborock_execute_program_job` uebernimmt die Schutzlogik.
4. Das Skript drueckt den echten Roborock-Button aus `program_map`.
5. Statussensoren und Diagnose-Helfer spiegeln Lauf, Erfolg oder Fehler zurueck ins Dashboard.

### Geplanter Start ueber den Wochenplan

1. Ein Slot-Zeittrigger der Scheduler-Automation feuert.
2. Die Automation validiert globalen Schalter, Busy-Lock, Wochentag und Slot-Aktivierung.
3. Die CSV-Jobfolge des Slots wird aus einem `input_text` gelesen.
4. `script.roborock_execute_job_chain` expandiert die Job-Aliase.
5. `script.roborock_execute_program_job` fuehrt die resultierende Programmfolge sicher aus.
6. Diagnose-Helfer, Logbook und Statussensoren bilden den Ablauf sichtbar ab.

## Fehlerbehandlung und Troubleshooting

### Typische Fehlerbilder

| Symptom | Wahrscheinliche Ursache | Pruefung |
| --- | --- | --- |
| Scheduler startet nicht | `input_boolean.roborock_schedule_enabled` ist `off` | Globalen Schalter im Dashboard pruefen |
| Slot feuert nicht | Slot ist deaktiviert oder Wochentag passt nicht | `input_boolean.roborock_slot_enabled_*` und `input_datetime.*` pruefen |
| Programm startet nicht | Roboter ist blockiert oder Busy-Lock bereits aktiv | `binary_sensor.roborock_program_blocked` und `input_boolean.roborock_busy` pruefen |
| Programm bleibt haengen | Status geht nicht in Ready- oder Active-State ueber | `sensor.saros_20_set_status` und `input_text.roborock_last_error` pruefen |
| Falsches Programm laeuft | Alias-/Programm-Mapping unklar | `input_text.roborock_last_job` und `input_text.roborock_last_program_sequence` vergleichen |

### Wichtige Diagnose-Entitaeten

- `input_text.roborock_last_error`
- `input_text.roborock_current_program`
- `input_text.roborock_last_program_sequence`
- `input_text.roborock_last_job`
- `input_text.roborock_last_slot`
- `sensor.saros_20_set_status`
- `sensor.saros_20_set_letzter_reinigungsbeginn`
- `binary_sensor.roborock_program_ready`
- `binary_sensor.roborock_program_blocked`

### Verhalten bei Fehlern

- Der Executor finalisiert aktiv und versucht Busy-Lock-Leichen zu vermeiden.
- Fehlertexte werden in `input_text.roborock_last_error` geschrieben.
- Logbook-Meldungen enthalten Quelle und Slot-Kontext.
- Nach HA-Neustart setzt eine eigene Automation den Busy-Zustand verzoegert zurueck.

## Migration Notes

- `roborock_jobs.yaml` enthaelt eine Migrationsnotiz fuer die Slot-Zeit-Helfer:
  Nach Entfernung von `initial:` koennen die bisherigen Standardzeiten einmalig mit
  `script.roborock_slot_time_bootstrap_manual` gesetzt werden.
- Die Job-Alias-Schicht bleibt fuer Scheduler- und UI-Kompatibilitaet erhalten,
  waehrend `program_map` die kanonische Abbildung auf echte Buttons bleibt.

## Diagramme

Die bearbeitbaren Flussdiagramme liegen in:

- `roborock_app_flows.drawio`

Die Datei enthaelt drei Seiten:

1. `Gesamtuebersicht`
2. `Scheduler`
3. `Programmausfuehrung`

## Validierungs-Checkliste

Die Dokumentation wurde gegen den aktuellen Stand aus folgenden Dateien erstellt:

- `D:\Codex\packages\roborock\roborock_core.yaml`
- `D:\Codex\packages\roborock\roborock_jobs.yaml`
- `D:\Codex\dashboards\roborock.yaml`
- `D:\Codex\dashboards\sieker_hub.yaml`

### Checkpunkte

- Vorhandene Core-, Job- und Dashboard-Dateien gelesen
- Kanonische `program_map` dokumentiert
- Job-Alias-`job_map` dokumentiert
- Scheduler-Struktur mit 7 Tagen x 3 Slots dokumentiert
- Busy-Lock-, Diagnose- und Fehlerpfade beschrieben
- Hub-Subviews `roborock*` als neuer Dashboard-Einstieg dokumentiert
- draw.io-kompatible Flussdiagramme erzeugt

## Einordnung

Die Roborock-App ist kein einzelnes YAML-Objekt, sondern ein zusammengesetztes
Home-Assistant-Modul aus Dashboard, Scheduler und Core-Executor. Die Architektur ist
vergleichsweise sauber getrennt: Das Dashboard startet nur sichere Skripte, der Scheduler
entscheidet nur ueber Zeit und Jobfolgen, und der Core kapselt die eigentliche Ausfuehrung
gegenueber dem Roborock-Geraet.
