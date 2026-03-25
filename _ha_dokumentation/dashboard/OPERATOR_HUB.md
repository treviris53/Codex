# Operator Hub

## Zweck

`dashboards/operator_hub.yaml` ist der neue MVP-Einstiegspunkt fuer eine eigene
operator-orientierte Frontend-Anwendung.

Das Ziel ist ausdruecklich **kein** Vollersatz der bestehenden YAML-Dashboards in
einem Schritt. Der Operator Hub verbindet stattdessen:

- einen kompakten Haus- und Modul-Hub
- eine kuratierte Raumansicht entlang der heutigen Wohn- und Umgebungsraeume
- kuratierte Fachmodule mit sicheren Einstiegspunkten

Damit dient das Dashboard als neue App-Shell fuer eine spaetere, schrittweise
Migration einzelner Fachmodule.

## Repo-Bestandteile

- `dashboards/operator_hub.yaml`
- `www/community/sieker-operator-hub/sieker-operator-hub.js`
- `configuration.yaml`

## Architekturmodell

Der Operator Hub folgt einem Hybrid-Ansatz:

- Fachlogik bleibt autoritativ in `packages/`
- bestehende Fachdashboards bleiben vorerst betriebliche Referenz
- das neue Frontend liest kuratierte Status-, Diagnose- und Tuning-Entitaeten
- Schreibzugriffe erfolgen bevorzugt ueber sichere `script.*`-Entry-Points

Das Frontend soll **keine** bestehende Fachlogik neu implementieren oder
Entscheidungen aus Registry-Daten erraten.

## Bedienmodell

### Home

`Home` ist ein verdichteter Leitstand fuer:

- Anwesenheit
- Heizung
- Rollladen-Zeitfenster
- Roborock-Status
- Wetterlage
- USV / Energie-nahe Basissicht
- Einstieg in Fachmodule

### Rooms

`Rooms` ist eine kuratierte Raumansicht entlang der heutigen Operator-Struktur.

Sie orientiert sich im MVP an den heute bereits genutzten Raeumen:

- `Kueche`
- `Wohnzimmer`
- `Schlafzimmer`
- `Bad`
- `Flur`
- `Gaestebad`
- `Gaestezimmer`
- `Balkon`

Der Fokus liegt auf:

- Raumklima
- Kontakte / Zugang
- relevante Rollladen- und Umgebungsdaten

Manuelle Alltagsbedienung bleibt bewusst ausserhalb der Raumansicht im
passenden Bedienkontext wie `Wohnen`.

Tiefere Diagnose-, Service- oder Tuning-Elemente gehoeren nicht in die
Raumansicht, sondern in Fachmodule.

### Modules

Module sind die kuratierten Fachansichten.

Im MVP gilt:

- `Heizung` ist die erste echte Vertikale
- `Rolllaeden`, `Roborock` und `Wetter` sind verdichtete Brueckenmodule
- Spezialkarten und bestehende Detail-Dashboards bleiben zunaechst erhalten

## MVP-Module

### Heizung

`Heizung` ist das Referenzmodul fuer die Zielarchitektur.

Es trennt bereits im MVP:

- Summary
- Status
- Safe Actions
- Diagnose
- Tuning
- Service-nahe Entitaeten

Die fachliche Autoritaet bleibt in den Heating-Packages und den bestehenden
Dokumenten unter `_ha_dokumentation/heating/`.

### Rolllaeden

Das Rollladen-Modul zeigt den Automatikstatus, zentrale Overrides,
Beschattungszustaende und Apply-Skripte.

Tiefe Beschattungslogik, Diagnose und Betriebsdetails bleiben vorerst in den
bestehenden Dashboards und Packages.

### Roborock

Das Roborock-Modul bietet im MVP nur einen sicheren, verdichteten Einstieg:

- aktuelle Statussicht
- Programmbereitschaft / Blockierung
- sichere Programmstarts ueber `script.roborock_run_named_program`

Map-Card, Wartung, Wochenplan und tiefere Bedienfluesse bleiben vorerst im
bestehenden Roborock-Dashboard.

### Wetter

Das Wetter-Modul ist eine Lagekarte fuer den schnellen Einstieg.

Radar, Weather-Chart-Card und Horizon-Card bleiben vorerst im bisherigen
Wetter-Dashboard.

## Integrationsmodell

### Lesen

Das Frontend liest:

- `hass.states`
- kuratierte, explizit referenzierte Raum- und Modul-Entitaeten

### Schreiben

Das Frontend schreibt bevorzugt ueber:

- `script.*`

Direkte Hardware-Steuerung ist im MVP nicht das Leitprinzip.

## Resource-Modell

`configuration.yaml` verwaltet Lovelace-Ressourcen fuer YAML-Dashboards mit:

- `lovelace:`
- `resource_mode: yaml`

Der Operator Hub wird dadurch als Repo-definierte Ressource eingebunden und
nicht nur implizit ueber die Storage-UI gepflegt.

## Build- und Pflegeansatz

Das MVP ist bewusst **buildless** umgesetzt.

Gruende:

- schneller Start ohne zusaetzliche Toolchain
- reviewbare erste Architektur im Repo
- geringer Aktivierungsaufwand fuer einen fruehen Pilot

Wenn sich das Bedienmodell bewaehrt, kann spaeter auf eine strukturierte
Frontend-Toolchain mit `frontend_apps/...` und Build-Ausgabe nach
`www/community/...` umgestellt werden.

## Grenzen des MVP

- keine Ablosung der bestehenden Fachdashboards
- keine Spezialvisualisierungen direkt im neuen Hub
- keine vollstaendige Modulnavigation fuer alle vorhandenen Fachdomänen
- keine eigene Build-Pipeline
- Raumansichten sind bewusst kompakt und noch nicht als tiefere Subviews ausgebaut

## Migrationshinweis

Der Operator Hub ist ein neuer Einstiegspunkt neben den bestehenden Dashboards.

Er ersetzt aktuell **nicht**:

- `dashboards/sieker_hub.yaml`
- `dashboards/sieker_dashboard.yaml`
- `dashboards/roborock.yaml`
- `dashboards/wetter_dashboard.yaml`

Eine Ablosung einzelner YAML-Dashboards soll erst nach betrieblicher Validierung
je Fachmodul entschieden werden.

## Validierung

- YAML mit `D:\Codex\.venv\Scripts\yamllint.cmd`
- Lovelace-Ressource in `configuration.yaml` geprueft
- keine bestehenden `entity_id` umbenannt
- keine Runtime-Dateien unter `W:\` bearbeitet
