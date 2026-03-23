# PowerShell-Skripte in `D:\Codex`

Diese Datei dokumentiert die vorhandenen PowerShell-Skripte im Workspace. Der Fokus liegt auf Zweck, Parametern, internen Funktionen und dem Datenfluss.

## Uebersicht

| Skript | Hauptzweck | Typische Ein-/Ausgabe |
| --- | --- | --- |
| `deploy_ha_git_guard.ps1` | Git- und YAML-Guard vor dem produktiven Deploy-Skript | Eingabe: relative YAML-Pfade und optionale Guard-Parameter; Ausgabe: Git-/Policy-Checks, delegiertes Deploy, lokale Deploy-Metadaten |
| `ha_api_test.ps1` | Minimaler Read-Only-Test gegen die Home-Assistant-REST-API | Eingabe: `HA_URL`, `HA_TOKEN`; Ausgabe: API-Antwort auf Konsole |
| `deploy_ha_samba.ps1` | Deployment ausgewaehlter Dateien/Ordner nach Home Assistant ueber Samba | Eingabe: lokale Pfade; Ausgabe: kopierte Dateien, optionale Backups, optionales Loeschen entfernter Dateien |
| `deploy_ha_samba_healthcheck.ps1` | Deployment mit Diff-, Reload- und Health-Check-Funktionen | Eingabe: lokale Pfade, API-Zugangsdaten; Ausgabe: Diff/Deploy-Logs, Reloads, API-Pruefung |
| `sync_ha_debug_roborock.ps1` | Erzeugt einen lokalen Debug-Snapshot fuer Roborock-bezogene Entity-States und Historie | Eingabe: API-Zugangsdaten; Ausgabe: JSON-Dateien und README unter `_ha_debug\roborock\...` |
| `sync_ha_debug_roborock_v2.ps1` | Erzeugt einen erweiterten Roborock-Debug-Snapshot mit Scheduler-, Script-, Button- und Logbook-Daten | Eingabe: API-Zugangsdaten, relatives oder explizites Zeitfenster; Ausgabe: erweiterte JSON-Dateien und README unter `_ha_debug\roborock\...` |
| `sync_ha_runtime_snapshot.ps1` | Kopiert zentrale `.storage`-Dateien lokal in `_ha_runtime_snapshot` | Eingabe: Dateiliste aus HA `.storage`; Ausgabe: lokale Snapshot-Dateien, optionale Backups |

## `deploy_ha_git_guard.ps1`

### Funktion

`deploy_ha_git_guard.ps1` ist ein konservativer Wrapper vor `deploy_ha_samba_healthcheck.ps1`. Er fuehrt vor produktionsnahen Deploys Git- und Policy-Pruefungen aus und delegiert danach an das bestehende Deploy-Skript.

### Zweck

- produktive Deploys nur aus dem Repository-Root `D:\Codex`
- optionaler Branch-Schutz fuer den Live-Workflow
- Blockade oder bewusste Freigabe bei dirty Worktrees
- harte YAML-only-Policy fuer Deploy-Pfade
- lokale Aufzeichnung des letzten erfolgreichen Guarded-Deploys unter `.deploy-state\`
- read-only Vorschau der committed YAML-Aenderungen seit dem letzten erfolgreichen Guarded-Deploy

### Wichtige Regeln

- Deploybar sind nur `.yaml`- und `.yml`-Dateien.
- Verzeichnisse duerfen nur deployt werden, wenn alle enthaltenen Dateien YAML-Dateien sind.
- Nicht-YAML-Dateien fuehren zum Abbruch; sie werden nicht stillschweigend uebersprungen.
- Die eigentlichen Runtime-Schreibzugriffe bleiben weiterhin auf `deploy_ha_samba_healthcheck.ps1` beschraenkt.
- `-ChangedSinceLastDeploy` ist eine reine Vorschau. Dieser Modus darf keine Aktivierung oder Statusfortschreibung ausloesen.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `SourceRoot` | `string` | `D:\Codex` | Repository-Wurzel fuer Git- und Pfadpruefung |
| `HaConfigRoot` | `string` | `W:\` | Zielwurzel der HA-Konfiguration |
| `Paths` | `string[]` | leer | Explizite relative YAML-Dateien oder YAML-only-Verzeichnisse |
| `Environment` | `string` | `live` | Name der Zielumgebung fuer die lokale Statusdatei |
| `ChangedSinceLastDeploy` | `switch` | `false` | Read-only-Vorschau der committed YAML-Aenderungen seit dem letzten erfolgreichen Guarded-Deploy |
| `AllowDirtyWorktree` | `switch` | `false` | Erlaubt bewusstes Deploy trotz uncommitteter oder ungetrackter Aenderungen |
| `RequireBranch` | `string` | leer | Erzwingt einen bestimmten Git-Branch fuer den Deploy |
| `Backup`, `WhatIf`, `DeleteRemoved`, `HealthCheck`, `StrictModeDeploy`, `DiffOnly`, `PostReload` | diverse | wie Basis-Skript | Werden an `deploy_ha_samba_healthcheck.ps1` weitergereicht |

### Datenfluss

**Quellen**

- Git-Metadaten aus dem Repository unter `D:\Codex`
- explizite Deploy-Pfade aus `Paths`
- optional Umgebungs- und API-Parameter fuer das Basis-Skript

**Verarbeitung**

1. validiert `SourceRoot` und den Git-Kontext: Repo-Root, Branch, HEAD-Commit, dirty/clean
2. im Normalmodus: validiert explizite YAML-only-Deploy-Pfade und delegiert an `deploy_ha_samba_healthcheck.ps1`
3. im Preview-Modus `-ChangedSinceLastDeploy`: liest `.deploy-state\<environment>.toml`, ermittelt committed YAML-Aenderungen seit dem letzten erfolgreichen Guarded-Deploy und leitet sichere Vorschlags-Pfade ab
4. schreibt nur bei erfolgreichem echtem Deploy eine lokale Statusdatei `.deploy-state\<environment>.toml`

**Ausgaben / Seiteneffekte**

- Konsolenlog fuer Guard-Checks
- im Normalmodus delegierter Diff oder echter Deploy ueber das Basis-Skript
- im Preview-Modus nur Vorschlagsausgabe, kein Runtime-Write
- lokale Deploy-Metadaten unter `.deploy-state\`

### Rollback-Einordnung

- operativer Rollback bleibt ueber die Backup-Funktion des Basis-Skripts moeglich
- revisionssicherer Rollback bleibt `git checkout <commit>` lokal plus normaler erneuter Deploy
- die Statusdatei ist nur Nachvollziehbarkeit, kein Rollback-Mechanismus

### Preview-Hinweise

- Der Preview-Modus betrachtet nur committed Git-Aenderungen zwischen dem letzten erfolgreichen Guarded-Deploy-Commit und `HEAD`.
- Uncommittete oder ungetrackte Worktree-Aenderungen werden im Preview-Modus nicht als Vorschlag beruecksichtigt; sie werden nur als Hinweis gemeldet.
- Wenn YAML-Dateien geloescht oder umbenannt wurden, versucht der Guard einen sicheren Verzeichnisvorschlag abzuleiten. Gelingt das nicht, wird der Fall als `UNRESOLVED` markiert.

## `ha_api_test.ps1`

### Funktion

`ha_api_test.ps1` ist ein sehr kleines Smoke-Test-Skript fuer die Home-Assistant-REST-API. Es prueft nur, ob eine authentifizierte GET-Anfrage gegen `/api/` erfolgreich ist.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `HaUrl` | `string` | `$env:HA_URL` | Basis-URL der Home-Assistant-Instanz |
| `Token` | `string` | `$env:HA_TOKEN` | Long-Lived Access Token fuer die REST-API |

### Interner Ablauf

1. Liest `HaUrl` und `Token` aus Parametern oder Umgebungsvariablen.
2. Validiert, dass beide Werte gesetzt sind.
3. Baut HTTP-Header mit `Authorization: Bearer ...`.
4. Sendet `GET {HaUrl}/api/`.
5. Gibt die API-Antwort als JSON auf der Konsole aus.
6. Bei Fehlern wird eine Fehlermeldung geschrieben und mit Exit-Code `1` beendet.

### Datenfluss

**Quellen**

- Parameter `HaUrl`
- Parameter `Token`
- alternativ `HA_URL` und `HA_TOKEN` aus der Umgebung

**Verarbeitung**

- URL wird zu `"{HaUrl}/api/"` erweitert
- Token wird in einen Bearer-Header ueberfuehrt
- Antwortobjekt von `Invoke-RestMethod` wird in JSON serialisiert

**Ausgaben / Seiteneffekte**

- Konsolenmeldung bei Erfolg
- JSON-Ausgabe der API-Root-Antwort
- Fehlerausgabe und Exit-Code `1` bei Fehlschlag

### Hinweise

- Das Skript ist read-only.
- Es ist gut geeignet, um Netzwerk, URL und Token getrennt von groesseren Deploy-Skripten zu testen.

## `deploy_ha_samba.ps1`

### Funktion

`deploy_ha_samba.ps1` kopiert explizit angegebene Dateien oder Verzeichnisse aus dem lokalen Workspace in das Home-Assistant-Konfigurationsverzeichnis auf einer Samba-Freigabe. Optional kann es vor dem Ueberschreiben Backups anlegen und nicht mehr vorhandene Zieldateien loeschen.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `SourceRoot` | `string` | `D:\Codex` | Lokale Wurzel fuer relative Deploy-Pfade |
| `HaConfigRoot` | `string` | `\\homeassistant\config` | Zielwurzel im Home-Assistant-Config-Share |
| `Paths` | `string[]` | leer | Relative Pfade, die deployt werden sollen |
| `Backup` | `switch` | `false` | Legt vor dem Ueberschreiben oder Entfernen Sicherungen an |
| `WhatIf` | `switch` | `false` | Dry-Run ohne Schreiboperationen |
| `DeleteRemoved` | `switch` | `false` | Entfernt Zieldateien, die im Quellpfad nicht mehr existieren |
| `BackupRoot` | `string` | leer | Ziel fuer Backups; faellt sonst auf `<HaConfigRoot>\backup_deploy` zurueck |
| `LogFile` | `string` | leer | Optionales Logfile zusaetzlich zur Konsole |

### Zentrale Funktionen

| Funktion | Aufgabe |
| --- | --- |
| `Write-Log` | Schreibt Zeitstempel-Logs auf Konsole und optional in Datei |
| `Assert-PathExists` | Validiert, dass wichtige Pfade existieren |
| `New-BackupPath` | Baut einen zeitgestempelten Backup-Zielpfad |
| `Ensure-ParentDirectory` | Erstellt bei Bedarf das Elternverzeichnis eines Zielpfads |
| `Copy-WithOptionalBackup` | Fuehrt Backup und anschliessendes Kopieren einer Datei aus |
| `Mirror-Directory` | Spiegelt ein Verzeichnis rekursiv und loescht optional entfernte Dateien |
| `Deploy-Path` | Entscheidet zwischen Datei- und Verzeichnis-Deployment |

### Datenfluss

**Quellen**

- `SourceRoot` plus relative Eintraege aus `Paths`
- bereits vorhandene Zielstruktur unter `HaConfigRoot`
- optionale Skriptflags `Backup`, `WhatIf`, `DeleteRemoved`

**Verarbeitung**

1. Validierung von `SourceRoot`, `HaConfigRoot` und `Paths`.
2. Initialisierung von `BackupRoot`, falls nicht uebergeben.
3. Iteration ueber jeden relativen Pfad aus `Paths`.
4. Fuer Dateien:
   - optional Backup der bestehenden Zieldatei
   - Kopie Quelle -> Ziel
5. Fuer Verzeichnisse:
   - rekursive Dateiliste aus dem Quellordner
   - Datei fuer Datei Kopie ins Ziel
   - optional Vergleich Ziel gegen Quelle und Entfernen verwaister Zieldateien

**Ausgaben / Seiteneffekte**

- Datei- und Verzeichnis-Kopien in `HaConfigRoot`
- optionale Backup-Dateien in `BackupRoot\<timestamp>\...`
- optionale Entfernung verwaister Dateien im Ziel
- Konsolenlog und optional Dateilog

### Wichtige Betriebsmodi

- `-WhatIf`: zeigt nur an, was passieren wuerde
- `-Backup`: sichert Zielstaende vor Veraenderungen
- `-DeleteRemoved`: macht das Ziel fuer die betroffenen Verzeichnisse naeher an ein echtes Mirror

### Risiken

- Mit `-DeleteRemoved` werden echte Dateien im Ziel entfernt, wenn sie lokal nicht mehr vorhanden sind.
- Ohne `-Backup` gibt es keine Rueckfallkopie vor dem Ueberschreiben.
- Das Skript arbeitet absichtlich nur mit explizit uebergebenen `-Paths` und verweigert implizite Defaults.

## `deploy_ha_samba_healthcheck.ps1`

### Funktion

Dieses Skript erweitert das einfache Samba-Deployment um drei Betriebsarten:

- Diff-Vorschau ohne Kopieren
- API-basierte Health-Checks gegen Home Assistant
- optionale Reload-Service-Calls nach dem Deployment

Damit ist es das sicherere und vielseitigere Deploy-Skript fuer kontrollierte Aenderungen.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `SourceRoot` | `string` | `D:\Codex` | Lokale Wurzel fuer relative Deploy-Pfade |
| `HaConfigRoot` | `string` | `W:\` | Zielwurzel der HA-Konfiguration |
| `Paths` | `string[]` | leer | Relative Pfade fuer Diff oder Deployment |
| `Backup` | `switch` | `false` | Aktiviert Backups vorhandener Zieldateien |
| `WhatIf` | `switch` | `false` | Dry-Run fuer Deploy-Operationen |
| `DeleteRemoved` | `switch` | `false` | Loescht verwaiste Zieldateien bei Verzeichnis-Mirror |
| `BackupRoot` | `string` | leer | Backup-Ziel, Default `<HaConfigRoot>\backup_deploy` |
| `LogFile` | `string` | leer | Optionales Dateilog |
| `HealthCheck` | `switch` | `false` | Aktiviert API-Pruefung nach dem Deployment |
| `HaUrl` | `string` | leer | HA-Basis-URL; faellt auf `HA_URL` zurueck |
| `HaToken` | `string` | leer | API-Token; faellt auf `HA_TOKEN` zurueck |
| `CheckEntities` | `string[]` | drei Roborock-bezogene Entities | Entities fuer den nachgelagerten State-Check |
| `StrictModeDeploy` | `switch` | `false` | Erzwingt konservativen Deploy-Modus |
| `DiffOnly` | `switch` | `false` | Zeigt nur Unterschiede, ohne zu kopieren |
| `PostReload` | `switch` | `false` | Ruft nach dem Deploy definierte Reload-Services auf |
| `ReloadServices` | `string[]` | `automation.reload`, `script.reload` | Service-Liste fuer `PostReload` |

### Zentrale Funktionen

| Funktion | Aufgabe |
| --- | --- |
| `Show-DiffSummary` | Vergleicht Quelle und Ziel per SHA-256 und protokolliert `ADD`, `CHANGE`, `DELETE`, `SAME` |
| `Get-FileHashSafe` | Liefert SHA-256 fuer vorhandene Dateien |
| `Invoke-HaHealthCheck` | Prueft API-Grundfunktion und liest definierte Entities |
| `Invoke-HaReloads` | Ruft HA-Services per REST auf |
| `Get-HaHeaders` | Baut Auth-Header fuer API-Operationen |
| `Deploy-Path`, `Mirror-Directory`, `Copy-WithOptionalBackup` | Wie im Basis-Deploy-Skript |

### Datenfluss

**Quellen**

- lokale Dateibaeume unter `SourceRoot`
- Zielpfade unter `HaConfigRoot`
- optionale HA-API-Zugangsdaten aus Parametern oder Umgebung
- optionale Listen `CheckEntities` und `ReloadServices`

**Verarbeitung**

1. Validiert Source- und Zielwurzel.
2. Liest `HaUrl` und `HaToken` notfalls aus Umgebungsvariablen.
3. Erzwingt bei `StrictModeDeploy`, dass `-Backup` aktiv und `-WhatIf` deaktiviert ist.
4. Iteriert ueber `Paths`.
5. Wenn `-DiffOnly` gesetzt ist:
   - berechnet Hashes fuer Quelle und Ziel
   - protokolliert nur Unterschiede
6. Sonst:
   - fuehrt echtes Deployment aus
   - optional Backups und Delete-Mirror
7. Wenn nicht `DiffOnly`:
   - optional `POST /api/services/<domain>/<service>` fuer jeden Reload-Service
   - optional `GET /api/` und `GET /api/states/<entity_id>` fuer den Health-Check

**Ausgaben / Seiteneffekte**

- Diff-Logs oder echte Dateioperationen
- optionale Backup-Dateien
- optionale DELETE-Operationen im Ziel
- optionale Reload-Calls an Home Assistant
- optionale API-Lesetests fuer definierte Entities

### Betriebslogik und Schutzmechanismen

- `-DiffOnly` unterdrueckt Kopieren, Reload und Health-Check.
- `-WhatIf` unterdrueckt Schreiboperationen sowie Health-Check/Reload.
- `-StrictModeDeploy` verhindert riskante Kombinationen und erzwingt Backup.
- API-Pruefungen werden nur ausgefuehrt, wenn sie explizit aktiviert wurden.

### Einordnung

Dieses Skript ist funktional eine superset-Variante von `deploy_ha_samba.ps1`. Fuer sichere Deployments mit Vorabvergleich ist es das staerkere Werkzeug.

## `sync_ha_debug_roborock.ps1`

### Funktion

`sync_ha_debug_roborock.ps1` sammelt einen zeitgestempelten Debug-Snapshot fuer eine feste Liste Roborock-bezogener Entities. Es speichert sowohl den aktuellen State als auch die Historie ueber ein konfigurierbares Zeitfenster.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `HaUrl` | `string` | `$env:HA_URL` | Basis-URL der HA-API |
| `HaToken` | `string` | `$env:HA_TOKEN` | Access Token fuer REST-Zugriff |
| `OutputRoot` | `string` | `.\_ha_debug\roborock` | Lokale Zielwurzel fuer den Snapshot |
| `HoursBack` | `int` | `12` | Rueckblick-Fenster fuer Historienabfragen |
| `WhatIf` | `switch` | `false` | Dry-Run ohne Dateischreiben |
| `IncludeTraceHints` | `switch` | `false` | Erweitert die README um Trace-Korrelationshinweise |

### Erfasste Entities

Das Skript arbeitet mit einer fest hinterlegten Liste:

- `sensor.saros_20_set_status`
- `sensor.saros_20_set_letzter_reinigungsbeginn`
- `sensor.saros_20_set_letztes_reinigungsende`
- `input_boolean.roborock_busy`
- `input_text.roborock_current_program`
- `input_text.roborock_last_error`
- `input_text.roborock_last_program_sequence`
- `input_text.roborock_last_slot`

### Zentrale Funktionen

| Funktion | Aufgabe |
| --- | --- |
| `Invoke-HaGet` | Fuehrt REST-GETs mit den vorbereiteten Headern aus |
| `New-TargetDirectory` | Erstellt das zeitgestempelte Zielverzeichnis |
| `Save-JsonFile` | Schreibt Datenobjekte als JSON-Dateien |
| `Save-TextFile` | Schreibt die zusammenfassende README |
| `Get-EntityState` | Liest den aktuellen State einer Entity |
| `Get-HistoryWindow` | Berechnet Start- und Endzeit im UTC-ISO-Format |
| `Get-EntityHistory` | Liest die Historie einer Entity aus `/api/history/period/...` |
| `Build-Summary` | Baut eine menschenlesbare Zusammenfassung |

### Datenfluss

**Quellen**

- `HaUrl` und `HaToken`
- statische Entity-Liste im Skript
- aktueller Zeitpunkt fuer das Zeitfenster

**Verarbeitung**

1. Validiert, dass URL und Token vorhanden sind.
2. Berechnet ein UTC-Zeitfenster von `now - HoursBack` bis `now`.
3. Baut ein Zielverzeichnis unter `OutputRoot\<timestamp>`.
4. Fuer jede Entity:
   - `GET /api/states/<entity>`
   - `GET /api/history/period/<start>?filter_entity_id=...&end_time=...`
5. Schreibt pro Entity eine History-Datei `<entity>_history.json`.
6. Schreibt alle aktuellen States gesammelt nach `current_states.json`.
7. Schreibt eine `README.txt` mit Metadaten und optionalen Trace-Hinweisen.

**Ausgaben / Seiteneffekte**

- neues Verzeichnis unter `_ha_debug\roborock\<timestamp>`
- eine JSON-History-Datei je Entity
- `current_states.json`
- `README.txt`

### Fehlerverhalten

- Fehler beim Lesen einzelner Entities werden pro Objekt als `error` abgelegt; das Skript versucht also, moeglichst viele Daten trotzdem mitzunehmen.
- Fehlende globale API-Zugangsdaten brechen das Skript sofort ab.

### Nutzzweck

Das Skript ist fuer Debugging und Ursachenanalyse gedacht, insbesondere fuer Roborock-Ablaufprobleme ueber einen begrenzten Zeitraum.

## `sync_ha_debug_roborock_v2.ps1`

### Funktion

`sync_ha_debug_roborock_v2.ps1` ist die erweiterte Nachfolgevariante fuer Roborock-Debugging. Es sammelt neben den bisherigen State- und History-Daten auch Scheduler-Snapshots, Script-States, Program-Button-Historien, gefilterte Logbook-Eintraege und zusaetzliche Current-State-Daten aus der Roborock-Integration.

### Zweck

- Ursachenanalyse fuer Scheduler-, Job-Chain- und Program-Executor-Probleme
- Korrelation zwischen Slot-Konfiguration, expandierten Jobs, gedrueckten Buttons und beobachtetem Geraeteverhalten
- read-only Datensammlung fuer spaetere maschinelle oder manuelle Auswertung

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `HaUrl` | `string` | `$env:HA_URL` | Basis-URL der HA-API |
| `HaToken` | `string` | `$env:HA_TOKEN` | Access Token fuer REST-Zugriff |
| `OutputRoot` | `string` | `.\_ha_debug\roborock` | Lokale Zielwurzel fuer den Snapshot |
| `HoursBack` | `int` | `1` | Standard-Rueckblick-Fenster, falls kein explizites Zeitfenster uebergeben wird |
| `StartTime` | `datetime` | nicht gesetzt | Optionaler lokaler Startzeitpunkt fuer das Capture |
| `EndTime` | `datetime` | nicht gesetzt | Optionaler lokaler Endzeitpunkt; nur gueltig zusammen mit `StartTime` |
| `WhatIf` | `switch` | `false` | Dry-Run ohne Dateischreiben |
| `IncludeTraceHints` | `switch` | `false` | Erweitert die README um Hinweise auf relevante Script-/Automation-Traces |

### Zeitfensterlogik

- Default: letzter Zeitraum `now - HoursBack` bis `now`
- explizit: `StartTime` bis `EndTime`
- Sonderfall: `StartTime` ohne `EndTime` bedeutet `StartTime` bis aktueller Zeitpunkt
- Schutz: `EndTime` ohne `StartTime` ist ungueltig und fuehrt zum Abbruch

### Erfasste Datenklassen

**1. Core-History**

- Roborock-Status- und Diagnose-Sensoren
- Busy-Lock und Busy-Zeitstempel
- aktuelle/letzte Job- und Program-Helper
- Ready-/Blocked-Binaersensoren
- relevante Roborock-Skripte
- Scheduler-Automation `automation.roborock_scheduler_woche_3_slots_4_jobs`

**2. Button-History**

- alle in `program_map` verwendeten Roborock-Button-Entities
- damit ist nachvollziehbar, welches Programm real per `button.press` ausgelost wurde

**3. Current-Only Snapshot**

- `vacuum.saros_20_set`
- Batterie, aktueller Raum, Reinigungszeit

**4. Scheduler-Snapshot**

- globaler Scheduler-Schalter
- Bootstrap-Helfer
- alle Slot-Enable-Helper
- alle Slot-Uhrzeiten
- alle Slot-Job-CSV-Helfer

**5. Logbook**

- Logbook-Eintraege fuer den Zeitbereich
- lokal gefiltert auf Roborock-relevante Entities, Script-/Automation-Namen und Roborock-Meldungen

### Zentrale Funktionen

| Funktion | Aufgabe |
| --- | --- |
| `Invoke-HaGet` | Fuehrt REST-GETs mit den vorbereiteten Headern aus |
| `Get-CaptureWindow` | Berechnet lokales und UTC-Zeitfenster aus `HoursBack` oder `StartTime`/`EndTime` |
| `Get-EntityState` | Liest den aktuellen State einer Entity |
| `Get-EntityHistory` | Liest die Historie einer Entity aus `/api/history/period/...` |
| `Get-LogbookWindow` | Liest das Logbook-Zeitfenster aus `/api/logbook/...` |
| `Get-RelevantLogbookEntries` | Filtert Roborock-relevante Logbook-Eintraege lokal aus |
| `Get-PropertyValue` | Liest Objekt-Properties defensiv, damit fehlende Felder das Skript nicht abbrechen |
| `New-SafeFileName` | Wandelt Entity-IDs in stabile Dateinamen um |
| `Build-Readme` | Erzeugt eine zusammenfassende README mit Capture-Metadaten |

### Datenfluss

**Quellen**

- `HaUrl` und `HaToken`
- fest hinterlegte Entity-Gruppen im Skript
- lokaler Start-/Endzeitpunkt oder `HoursBack`

**Verarbeitung**

1. Validiert URL/Token.
2. Berechnet das Capture-Fenster lokal und in UTC.
3. Baut ein Zielverzeichnis unter `OutputRoot\<timestamp>`.
4. Liest Current-State-Daten fuer alle konfigurierten Entities.
5. Trennt daraus den Scheduler-Snapshot ab.
6. Liest History-Daten fuer Core-, Script-, Automation- und Button-Entities.
7. Liest das Logbook-Zeitfenster und filtert Roborock-relevante Eintraege.
8. Schreibt Metadaten, Current-States, Scheduler-Snapshot, History-Dateien und README in das Zielverzeichnis.

**Ausgaben / Seiteneffekte**

- neues Verzeichnis unter `_ha_debug\roborock\<timestamp>`
- `entity_manifest.json`
- `current_states.json`
- `schedule_snapshot.json`
- `logbook_relevant.json`
- eine History-Datei je Entity aus den Gruppen `history_entities` und `button_entities`
- `README.txt`

### Typische Ausgabedateien

| Datei | Inhalt |
| --- | --- |
| `entity_manifest.json` | Liste aller erfassten Entity-Gruppen |
| `current_states.json` | gemeinsamer Snapshot aller Current-State-Entities |
| `schedule_snapshot.json` | Scheduler-, Slot- und Job-Konfiguration zum Capture-Zeitpunkt |
| `logbook_relevant.json` | lokal gefilterte Roborock-relevante Logbook-Eintraege |
| `*_history.json` | Historie einzelner Entities fuer den Capture-Zeitraum |
| `README.txt` | maschinen- und menschenlesbare Zusammenfassung des Snapshots |

### Fehlerverhalten

- fehlende globale API-Zugangsdaten brechen das Skript sofort ab
- ungueltige Zeitfensterparameter brechen das Skript sofort ab
- Fehler einzelner State-/History-/Logbook-Abfragen werden als `error` in den Ausgabedaten abgelegt
- der Logbook-Filter ist defensiv implementiert, damit fehlende Felder einzelner Eintraege das Skript nicht abbrechen

### Beispiele

```powershell
.\sync_ha_debug_roborock_v2.ps1
```

```powershell
.\sync_ha_debug_roborock_v2.ps1 -HoursBack 6
```

```powershell
.\sync_ha_debug_roborock_v2.ps1 -StartTime "2026-03-22 08:00" -EndTime "2026-03-22 11:00"
```

### Einordnung

- `sync_ha_debug_roborock.ps1` bleibt die kleinere, feste Basisvariante
- `sync_ha_debug_roborock_v2.ps1` ist die bevorzugte Variante fuer Debugging von Scheduler-, Folgejob- und Startkorrelationsproblemen

## `sync_ha_runtime_snapshot.ps1`

### Funktion

`sync_ha_runtime_snapshot.ps1` kopiert ausgewaehlte Dateien aus `Home Assistant/.storage` in einen lokalen Snapshot-Ordner. Das ist vor allem fuer Offline-Analyse und Vergleich von Registry- und Runtime-Daten gedacht.

### Parameter

| Parameter | Typ | Default | Bedeutung |
| --- | --- | --- | --- |
| `HaConfigRoot` | `string` | `W:\` | Wurzel der Home-Assistant-Konfiguration |
| `LocalSnapshotRoot` | `string` | `D:\Codex\_ha_runtime_snapshot` | Lokale Zielwurzel |
| `Files` | `string[]` | vier zentrale `.storage`-Dateien | Zu kopierende Dateinamen |
| `Backup` | `switch` | `false` | Sichert bestehende lokale Dateien vor dem Ueberschreiben |
| `WhatIf` | `switch` | `false` | Dry-Run ohne Schreiboperationen |

### Standard-Dateiliste

- `core.entity_registry`
- `core.device_registry`
- `core.config_entries`
- `core.restore_state`

### Interner Ablauf

1. Bildet `sourceStorage = <HaConfigRoot>\.storage`.
2. Bildet `targetStorage = <LocalSnapshotRoot>\.storage`.
3. Prueft, ob die Quellstruktur existiert.
4. Erstellt den lokalen Zielordner bei Bedarf.
5. Iteriert ueber die angegebene Dateiliste.
6. Fuer jede Datei:
   - ueberspringt sie, wenn die Quelle fehlt
   - erstellt optional ein zeitgestempeltes Backup der bestehenden lokalen Datei
   - kopiert Quelle -> lokales Ziel

### Datenfluss

**Quellen**

- Home-Assistant-Dateien unter `<HaConfigRoot>\.storage`
- dateinamebasierte Auswahl ueber `Files`

**Verarbeitung**

- Join von Wurzelpfaden und Dateinamen
- optional Backup lokaler Zielstaende nach `backup_<timestamp>`
- anschliessende Aktualisierung des lokalen Snapshots

**Ausgaben / Seiteneffekte**

- aktualisierte lokale Snapshot-Dateien unter `_ha_runtime_snapshot\.storage`
- optionale Backup-Dateien unter `_ha_runtime_snapshot\backup_<timestamp>\...`
- Konsolenlog fuer Copy-, Skip- und Backup-Schritte

### Hinweise

- Das Skript kopiert nur die explizit genannten `.storage`-Dateien, nicht den gesamten Ordner.
- Es ist bewusst auf einen kleinen, analysierbaren Teil der Runtime-Daten begrenzt.

## Zusammenfassung nach Kategorie

### 1. API-Test und API-Debug

- `ha_api_test.ps1`: sehr kleiner Verbindungs- und Auth-Test
- `sync_ha_debug_roborock.ps1`: gezielte Datensammlung ueber REST fuer Roborock
- `sync_ha_debug_roborock_v2.ps1`: erweiterte Roborock-Datensammlung mit Scheduler-, Button- und Logbook-Kontext

### 2. Deployment

- `deploy_ha_git_guard.ps1`: Git- und YAML-Policy-Guard vor dem produktionsnahen Deployment
- `deploy_ha_samba.ps1`: direktes Dateideployment mit optionalem Backup/Mirror
- `deploy_ha_samba_healthcheck.ps1`: Deployment plus Diff, Reload und Health-Check

### 3. Snapshot / Offline-Analyse

- `sync_ha_runtime_snapshot.ps1`: lokale Kopie wichtiger `.storage`-Dateien

## Praktische Reihenfolge im Einsatz

1. `ha_api_test.ps1`, wenn zuerst nur URL/Token geprueft werden sollen.
2. `deploy_ha_git_guard.ps1 -DiffOnly`, um Git- und YAML-Guard plus Aenderungen vorab zu sehen.
3. `deploy_ha_git_guard.ps1` mit `-Backup`, falls ein kontrolliertes produktionsnahes Deployment folgen soll.
4. `sync_ha_runtime_snapshot.ps1`, wenn lokale Registry-/Runtime-Analyse benoetigt wird.
5. `sync_ha_debug_roborock.ps1`, wenn Roborock-bezogene Laufzeitdaten oder Historien fuer Debugging gebraucht werden.
6. `sync_ha_debug_roborock_v2.ps1`, wenn Roborock-Ablauf, Scheduler-Konfiguration, Button-Ausloesungen und Logbook gemeinsam korreliert werden sollen.
