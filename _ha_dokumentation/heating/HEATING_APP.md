# Heating-App in `D:\Codex`

Diese Datei dokumentiert die Heating-App im Home-Assistant-Workspace. Der Fokus liegt
auf Zweck, Architektur, Helfern, Sollprofil-Logik, Szenenanwendung, Manual-Override,
Dashboard-Einstiegen und dem End-to-End-Datenfluss zwischen Entscheidung und Thermostaten.

## Uebersicht

| Baustein | Datei | Hauptzweck |
| --- | --- | --- |
| Helper Layer | `packages/heating/heating_helpers.yaml` | Haelt Betriebsflags, Schwellenwerte, Diagnose-Helper und Override-Timer |
| Decision Layer | `packages/heating/heating_templates.yaml` | Berechnet Anwesenheit stabil, Sollprofil und Diagnoseattribute |
| Execution Layer | `packages/heating/heating_scripts.yaml` | Wendet Profile ueber autoritative Szenen auf die Climates an |
| Automation Layer | `packages/heating/heating_automations.yaml` | Steuert geplante Anwendungen, Sonderfaelle und Override-Lifecycle |
| Scene Layer | `packages/heating/heating_scenes.yaml` | Definiert die autoritativen Runtime-Szenen fuer 17, 19 und 21 Grad |
| Dashboard / UI | `dashboards/sieker_dashboard.yaml`, `dashboards/sieker_hub.yaml`, `dashboards/sieker_hub_v2.yaml` | Bietet Legacy-Subview-Zugriff sowie die Hub-Varianten v1 und v2 mit Übersicht, Diagnose, Service und Tuning |

## Zweck der App

Die Heating-App kapselt vier Aufgaben:

1. Berechnung eines fachlichen Sollprofils fuer eine traege Fussbodenheizung.
2. Geplante Anwendung dieses Profils ueber Home-Assistant-Szenen.
3. Erkennung manueller Eingriffe an Climates und temporaere Pausierung der Automatik.
4. Nachvollziehbare Diagnose ueber Helper, Sensorattribute, Timer und Dashboard-Ansichten.

## Architektur

Die Implementierung folgt einer klaren Schichtung:

- Helpers speichern Betriebsmodus, Schwellwerte und Diagnosezustand.
- Templates berechnen die fachliche Empfehlung, aber steuern keine Thermostate direkt.
- Das Apply-Skript ist der autoritative Ausfuehrungspfad fuer die automatische Regelung.
- Automationen entscheiden, wann das Sollprofil angewendet oder ein Override gestartet bzw. beendet wird.
- Szenen definieren die eigentlichen Thermostatvorgaben.
- Das Dashboard visualisiert Eingaben, Entscheidungen und Service-Einstiege.

## Abhaengigkeiten

### Externe Home-Assistant-Entitaeten

Die App nutzt unter anderem:

- `input_boolean.anwesend`
- `binary_sensor.winterbetrieb_empfohlen`
- `sensor.hamburg_fu_temp_next12h_max`
- `sensor.season`
- Climate-Entities wie:
  - `climate.flur_wandthermostat`
  - `climate.gaste_wandthermostat`
  - `climate.gastebad_wandthermostat`
  - `climate.kuche_wandthermostat`
  - `climate.schlazi_wandthermostat`
  - `climate.wohnzimmer_wandthermostat`
  - `climate.wohnraum_flur_int0000004`

### Paketinterne Abhaengigkeiten

- `sensor.heizung_sollprofil` ist die fachliche Soll-Entscheidung.
- `script.heizung_profil_anwenden_pkg` konsumiert das Sollprofil oder einen expliziten Profilparameter.
- `heating_automations.yaml` ruft das Apply-Skript zu festen Zeiten und bei Sonderfaellen auf.
- `heating_scenes.yaml` ist der autoritative Runtime-Pfad fuer die automatische 3-Profil-Regelung.
- `input_boolean.heizung_override` blockiert die automatische Anwendung temporaer.

## `packages/heating/heating_helpers.yaml`

### Funktion

Diese Datei enthaelt die benutzer- und betriebsnahen Helper fuer Heizungsautomatik,
Debug, Urlaub, Override, Sommer-/Abwesenheitsschwellen und Diagnosefelder.

### Wichtige Helper

| Entity | Zweck |
| --- | --- |
| `input_boolean.heizung_automatik` | Master-Schalter fuer die Heizungsautomatik |
| `input_boolean.heizung_debug` | Aktiviert zusaetzliches Logbook-Debugging |
| `input_boolean.heizung_urlaub` | Erzwingt das Urlaubsprofil `eco_17` |
| `input_boolean.heizung_override` | Pausiert die automatische Profilanwendung nach manuellem Eingriff |
| `timer.heizung_override` | Laufzeit des Override-Fensters, Default 2 Stunden |
| `input_number.heizung_temperatur_sommer` | Schwellwert fuer die Tagesmax-Prognose |
| `input_number.heizung_abwesenheit_stunden` | Schwelle fuer stabile Langabwesenheit |
| `input_select.heizung_aktives_profil` | Diagnose- und UI-Helfer fuer das zuletzt angewendete Profil |
| `input_datetime.heizung_last_applied` | Zeitstempel der letzten erfolgreichen Szenenanwendung |
| `input_text.heizung_last_scene` | Zuletzt aktivierte Szene |
| `input_text.heizung_last_action` | Letzte textuelle Entscheidungsnotiz |

## `packages/heating/heating_templates.yaml`

### Funktion

Diese Datei berechnet die fachliche Entscheidungsgrundlage der Heating-App.
Sie enthaelt keine direkte Ausfuehrungslogik gegen die Climates.

### Wichtige Templates

| Entity | Zweck |
| --- | --- |
| `binary_sensor.anwesend_stabil` | Glaettet die Anwesenheitsquelle ueber die Abwesenheitsschwelle |
| `sensor.heizung_sollprofil` | Berechnet `eco_17`, `eco_19` oder `komfort_21` |
| `binary_sensor.heizung_gaste_fenster_offen` | Fensterdiagnose fuer den Gaestebereich |

### Entscheidungslogik von `sensor.heizung_sollprofil`

Das Sollprofil wird in dieser Reihenfolge bestimmt:

1. Wenn `input_boolean.heizung_urlaub = on`, dann `eco_17`.
2. Wenn `binary_sensor.anwesend_stabil = off`, dann `eco_19`.
3. Wenn `binary_sensor.winterbetrieb_empfohlen = on`, dann `komfort_21`.
4. Wenn `sensor.hamburg_fu_temp_next12h_max < input_number.heizung_temperatur_sommer`, dann `komfort_21`.
5. Sonst `eco_19`.

### Wichtige Diagnoseattribute des Sollprofils

- `grund`
- `decision_chain`
- `urlaub`
- `anwesend_stabil`
- `winterbetrieb_empfohlen`
- `tx_dwd`
- `sommer_schwellwert`
- `automatik_enabled`
- `debug_enabled`
- `last_profile`
- `last_profile_change_local`
- `last_applied_local`
- `last_action_text`
- `last_scene`

## `packages/heating/heating_scenes.yaml`

### Funktion

Diese Datei definiert die autoritativen Runtime-Szenen der automatischen Heizregelung.
Jede Szene setzt die relevanten Climates in `state: auto` mit einem festen `preset_mode`.

### Szenen

| Szene | Profil | Preset |
| --- | --- | --- |
| `scene.heizung_17deg` | `eco_17` | `week_program_4` |
| `scene.heizung_19deg` | `eco_19` | `week_program_3` |
| `scene.heizung_21deg` | `komfort_21` | `week_program_1` |

Betroffene Climates:

- `climate.flur_wandthermostat`
- `climate.gaste_wandthermostat`
- `climate.gastebad_wandthermostat`
- `climate.kuche_wandthermostat`
- `climate.schlazi_wandthermostat`
- `climate.wohnzimmer_wandthermostat`

## `packages/heating/heating_scripts.yaml`

### Funktion

Das Skript `script.heizung_profil_anwenden_pkg` ist der zentrale Ausfuehrungspfad der
automatischen Heating-App. Es waehlt die passende Szene, aktiviert sie und schreibt
anschliessend Diagnose- und Statushelper.

### Eingaben

| Feld | Bedeutung |
| --- | --- |
| `profil` | Optional explizites Profil; ohne Wert wird `sensor.heizung_sollprofil` verwendet |

### Interner Ablauf

1. Bestimmt `profil_effektiv`.
2. Loest die zugehoerige Szene fuer Urlaub, Eco oder Komfort auf.
3. Blockiert die Ausfuehrung, wenn `input_boolean.heizung_override = on`.
4. Blockiert die Ausfuehrung, wenn `input_boolean.heizung_automatik = off`.
5. Aktiviert die passende Szene.
6. Aktualisiert `input_select.heizung_aktives_profil`.
7. Aktualisiert `input_datetime.heizung_last_applied`.
8. Schreibt `input_text.heizung_last_action` und `input_text.heizung_last_scene`.
9. Optional wird bei aktivem Debug ein Logbook-Eintrag erzeugt.

### Legacy- und Kompatibilitaetspfade

- Fallbacks auf `scene.heizung_17deg_2`, `scene.heizung_19deg_2` und `scene.heizung_21deg_2`
  bleiben bewusst erhalten.
- Root-Szenen in `scenes.yaml` werden laut Ownership-Kommentar nicht automatisch konsolidiert.

## `packages/heating/heating_automations.yaml`

### Funktion

Diese Datei steuert den Lifecycle der automatischen Heizungsregelung:
geplante Profilanwendung, Sofortanwendungen fuer Sonderfaelle und den kompletten
Manual-Override-Pfad inklusive Timer-Reconcile nach Neustart.

### Wichtige Automationen

| ID | Aufgabe |
| --- | --- |
| `heizung_sollprofil_sync` | Hauptautomation fuer taegliche bzw. ereignisbasierte Profilanwendung |
| `heizung_automatik_einschalten_sync` | Wendet beim Einschalten der Automatik sofort das Sollprofil an |
| `heizung_override_timer_start` | Startet den Override-Timer |
| `heizung_override_timer_cancel` | Stoppt den Override-Timer bei manuellem Ruecksetzen |
| `heizung_override_timer_finished` | Beendet den Override und wendet das Sollprofil wieder an |
| `heizung_override_auto_detect` | Erkennt manuelle Aenderungen an den Climates |
| `heizung_override_startup_reconcile` | Stellt Timer-/Boolean-Konsistenz nach HA-Start wieder her |

### Betriebsmodell der Profilanwendung

Laut Kommentar ist die Fussbodenheizung bewusst traege modelliert:

- `04:03` ist der fachliche Hauptzeitpunkt fuer die Tagesvorgabe.
- `00:01` dient als Re-Apply nach Mitternacht.
- Sofortige Anwendungen passieren nur bei Sonderfaellen:
  - HA-Start
  - Automatik EIN
  - Urlaub aendert sich
  - Override-Ende

### Manual-Override-Erkennung

`heizung_override_auto_detect` beobachtet Temperatur-, `preset_mode`- und State-Aenderungen
relevanter Climate-Entities fuer jeweils 5 Sekunden. Ein Override wird nur gesetzt, wenn:

- die Automatik aktiv ist
- noch kein Override aktiv ist
- sich der beobachtete Wert tatsaechlich geaendert hat
- die letzte automatische Anwendung mehr als 120 Sekunden her ist

### Override-Lifecycle

1. Manueller Eingriff erkannt.
2. `input_boolean.heizung_override` wird auf `on` gesetzt.
3. `timer.heizung_override` startet mit 2 Stunden Laufzeit.
4. Waehrenddessen blockiert das Apply-Skript die Automatik.
5. Nach `timer.finished` wird das Override wieder ausgeschaltet.
6. Anschliessend wird das aktuelle Sollprofil erneut angewendet.

## Dashboard-Einstiege in `dashboards/sieker_dashboard.yaml`, `dashboards/sieker_hub.yaml` und `dashboards/sieker_hub_v2.yaml`

### Funktion

Die Heating-App besitzt drei Dashboard-Einstiege:

- Legacy in `sieker_dashboard.yaml`
- Hub v1 in `sieker_hub.yaml`
- Hub v2 in `sieker_hub_v2.yaml`

### Legacy-Subviews in `sieker_dashboard.yaml`

- `path: heizung`
- `path: heizung-debug`

### Hub-Subviews in `sieker_hub.yaml` und `sieker_hub_v2.yaml`

- `path: heizung`
- `path: heizung-diagnose`
- `path: heizung-service`
- `path: heizung-tuning`

### Inhalte der Legacy-Hauptansicht `heizung`

| Bereich | Inhalt |
| --- | --- |
| Betrieb | Automatik, Urlaub, Debug, aktives Profil, Override, Override-Timer |
| Stellschrauben | Abwesenheitsschwelle und Sommer-Schwellwert |
| Status | Anwesenheit, Winterbetrieb, Vorhersage, Saison, Sollprofil, letzte Anwendung |
| Historie | Profil- und Wetterverlaeufe |

### Inhalte der Legacy-Debug-Ansicht `heizung-debug`

| Bereich | Inhalt |
| --- | --- |
| Entscheidungen & Gruende | State und Attribute von `sensor.heizung_sollprofil` |
| Eingaenge | Rohwerte fuer Automatik, Urlaub, Anwesenheit, Winterbetrieb und Wetter |
| Service | Manueller Start von `script.heizung_profil_anwenden_pkg` |
| Historie | Langfristige Profilverlaeufe |

### Inhalte des Hub-Einstiegs `heizung`

| Bereich | Inhalt |
| --- | --- |
| Betrieb | Sollprofil, aktives Profil, letzte Anwendung, Override-Status |
| Eingangslage | Anwesenheit, Winterbetrieb, Vorhersage und Saison |
| Untermenues | Navigation nach Diagnose, Service und Tuning |
| Kurz-Historie | Profil- und Wetterverlauf ueber 24h |

### Inhalte der Hub-Ansicht `heizung-diagnose`

| Bereich | Inhalt |
| --- | --- |
| Entscheidungen | State und Kernattribute von `sensor.heizung_sollprofil` |
| Rohwerte | Urlaub, Wetter- und Praesenzinputs |
| Historie | Profilwechsel ueber 7 Tage |

### Inhalte der Hub-Ansicht `heizung-service`

| Bereich | Inhalt |
| --- | --- |
| Anwenden | Sicht auf Sollprofil, aktives Profil, letzte Szene, letzte Anwendung und manuellen Start von `script.heizung_profil_anwenden_pkg` |
| Betriebsbild | Relevante Override- und Diagnose-Helper |

### Inhalte der Hub-Ansicht `heizung-tuning`

| Bereich | Inhalt |
| --- | --- |
| Betriebsmodus | Heizungsautomatik und Debug-Logging |
| Stellschrauben | Abwesenheitsschwelle und Sommer-Schwellwert |
| Hinweise | Bedienhinweise ohne Aenderung der fachlichen Laufzeitlogik |

## End-to-End-Datenfluss

### Fachliche Profilentscheidung

1. Anwesenheit, Urlaub, Winterempfehlung und Wetterdaten aktualisieren sich.
2. `binary_sensor.anwesend_stabil` glattet die Anwesenheit.
3. `sensor.heizung_sollprofil` berechnet das fachliche Zielprofil.
4. Diagnoseattribute machen Grund und Entscheidungskette sichtbar.

### Geplante oder ereignisbasierte Anwendung

1. Eine Heating-Automation feuert.
2. Automatik muss `on` und Override `off` sein.
3. `script.heizung_profil_anwenden_pkg` wird aufgerufen.
4. Das Skript waehlt die passende Szene.
5. Die Szene setzt die beteiligten Climates auf ihren Preset-Pfad.
6. Diagnose-Helper werden aktualisiert.

### Manueller Eingriff

1. Ein Climate wird manuell veraendert.
2. `heizung_override_auto_detect` erkennt die Aenderung.
3. Override-Boolean und Timer werden aktiviert.
4. Waehrend des Timers blockiert das Apply-Skript die Automatik.
5. Nach Ablauf wird das Sollprofil erneut angewendet.

## Fehlerbehandlung und Troubleshooting

### Typische Fehlerbilder

| Symptom | Wahrscheinliche Ursache | Pruefung |
| --- | --- | --- |
| Kein Profilwechsel | `input_boolean.heizung_automatik` ist `off` | Hauptschalter im Dashboard pruefen |
| Profil wird nicht angewendet | `input_boolean.heizung_override` ist `on` | Override und Timer pruefen |
| Falsches Profil | Eingangslogik liefert anderen Grund | `sensor.heizung_sollprofil` und Attribut `grund` pruefen |
| Override endet nicht | Timer/Boolean nach Neustart inkonsistent | `timer.heizung_override` und Startup-Reconcile pruefen |
| Keine Logs | Debug nicht aktiv | `input_boolean.heizung_debug` pruefen |

### Wichtige Diagnose-Entitaeten

- `sensor.heizung_sollprofil`
- `input_select.heizung_aktives_profil`
- `input_datetime.heizung_last_applied`
- `input_text.heizung_last_action`
- `input_text.heizung_last_scene`
- `input_boolean.heizung_override`
- `timer.heizung_override`
- `binary_sensor.anwesend_stabil`
- `binary_sensor.winterbetrieb_empfohlen`

## Migration Notes

- `heating_scenes.yaml` ist der autoritative Runtime-Pfad der automatischen 3-Profil-Regelung.
- Root-Szenen und Legacy-Fallbacks bleiben bewusst fuer Kompatibilitaet bestehen.
- Die Diagnose-Helfer sind UI- und Analysepfade, aber nicht die alleinige autoritative Heizungswahrheit.

## Diagramme

Die bearbeitbaren Flussdiagramme liegen in:

- `heating_app_flows.drawio`

Die Datei enthaelt drei Seiten:

1. `Gesamtuebersicht`
2. `Profilentscheidung`
3. `Override-Lifecycle`

## Validierungs-Checkliste

Die Dokumentation wurde gegen den aktuellen Stand aus folgenden Dateien erstellt:

- `D:\Codex\packages\heating\heating_helpers.yaml`
- `D:\Codex\packages\heating\heating_templates.yaml`
- `D:\Codex\packages\heating\heating_scripts.yaml`
- `D:\Codex\packages\heating\heating_automations.yaml`
- `D:\Codex\packages\heating\heating_scenes.yaml`
- `D:\Codex\dashboards\sieker_dashboard.yaml`
- `D:\Codex\dashboards\sieker_hub.yaml`

### Checkpunkte

- Helper-, Template-, Script-, Automation- und Scene-Layer gelesen
- Sollprofil-Reihenfolge dokumentiert
- Override-Erkennung und Timer-Lifecycle dokumentiert
- Legacy-Dashboard-Subviews `heizung` und `heizung-debug` aufgenommen
- Hub-Subviews `heizung`, `heizung-diagnose`, `heizung-service` und `heizung-tuning` aufgenommen
- draw.io-kompatible Flussdiagramme erzeugt

## Einordnung

Die Heating-App ist eine bewusst traege, szenenbasierte Profilsteuerung fuer die
Fussbodenheizung. Die fachliche Entscheidung entsteht in Templates, die operative
Ausfuehrung in genau einem Apply-Skript, und manuelle Bedienung wird nicht bekaempft,
sondern ueber einen zeitlich begrenzten Override respektiert.
