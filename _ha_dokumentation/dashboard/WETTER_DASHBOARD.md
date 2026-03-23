# Wetter-Dashboard

## Zweck

`dashboards/wetter_dashboard.yaml` ist das operator-orientierte Wetter-Dashboard
für DWD-Daten der Station Hamburg-Fuhlsbüttel.

Das Dashboard trennt:

- schnelle Wetterlage
- Radar-Lagebild
- tiefe DWD-Kennzahlen und Diagnose

Damit bleibt die Startansicht kompakt, während Detaildaten und Diagnose nicht
mehr in einer langen Einzelansicht untergehen.

## Datenbasis

Autoritative Wetterquelle ist:

- `weather.hamburg_fu`

Verwendete DWD-Sensoren umfassen unter anderem:

- `sensor.hamburg_fu_wetterzustand`
- `sensor.hamburg_fu_temperatur`
- `sensor.hamburg_fu_tx_heute`
- `sensor.hamburg_fu_tn_heute`
- `sensor.hamburg_fu_temp_next12h_max`
- `sensor.hamburg_fu_temp_next12h_min`
- `sensor.hamburg_fu_luftfeuchtigkeit`
- `sensor.hamburg_fu_absolute_luftfeuchtigkeit`
- `sensor.hamburg_fu_taupunkt`
- `sensor.hamburg_fu_druck`
- `sensor.hamburg_fu_niederschlag`
- `sensor.hamburg_fu_niederschlagswahrscheinlichkeit`
- `sensor.hamburg_fu_precip_probability_next1h`
- `sensor.hamburg_fu_precip_sum_24h`
- `sensor.hamburg_fu_windgeschwindigkeit`
- `sensor.hamburg_fu_windboen`
- `sensor.hamburg_fu_windrichtung`
- `sensor.hamburg_fu_windrose`
- `sensor.hamburg_fu_beaufort`
- `sensor.hamburg_fu_sichtweite`
- `sensor.hamburg_fu_bewolkungsgrad`
- `sensor.hamburg_fu_nebelwahrscheinlichkeit`
- `sensor.hamburg_fu_sonneneinstrahlung`
- `sensor.hamburg_fu_sonnenscheindauer`
- `sensor.hamburg_fu_vorhersagezeit_local`

Radar-Karten:

- `camera.precipitation_3` für 35 km
- `camera.precipitation_2` für 250 km

## Informationsarchitektur

### Aktuell

`Aktuell` ist die primäre Entscheidungsansicht.

Sie zeigt:

- Schnellnavigation zu Radar, Vorhersage und DWD-Details
- Hero-Karte mit aktueller Temperatur, Wetterzustand und Tages-Spanne
- eigene Hinweiszeile mit `Tagesfokus`, `Warnlage` und `DWD-Datenstand`
- Risiko-Scan mit Gauges fuer Regen, Boeen und Sichtweite
- kompaktes Schnellbild fuer Regen, Wind, Luft, Sicht und Sonne
- Stunden-Forecast für die nächsten Stunden
- verbreiterten Trendbereich für Einordnung, Mehrtages-Trend und Temperaturverlauf

### Radar

`Radar` ist das Niederschlags-Lagebild.

Sie zeigt:

- lokales Radar 35 km
- regionales Radar 250 km
- textliche Radar-Einordnung für die lokale Regenlage
- flankierende Niederschlags- und Sicht-Kennzahlen

### DWD Details

`DWD-Details` ist die Fach- und Diagnoseansicht.

Sie ordnet die Detaildaten in ruhigen, breiten Doppelzeilen:

- `Thermik und Atmosphäre`
- `Verlauf und Wind`
- `Niederschlag und Strahlung`
- `Astronomie`

Damit bleibt die Startansicht frei von Rohdaten-Überladung.
Die `horizon-card` steht in einer eigenen breiten Astronomie-Sektion und wird nicht mehr zwischen Kennzahlen eingequetscht.

## Bedienfluss

Empfohlener Ablauf:

1. `Aktuell` für schnelle Lageeinschätzung nutzen.
2. Bei Niederschlagslage in `Radar` wechseln.
3. Bei Analyse oder Plausibilisierung in `DWD-Details` wechseln.

## Abhaengigkeiten

- DWD Weather Integration für `weather.hamburg_fu`, DWD-Sensoren und Radar-Kameras
- `custom:button-card`
- `custom:weather-chart-card`
- `custom:horizon-card`

## Inputs / Parameter

Das Dashboard setzt keine eigenen Runtime-Parameter und keine zweite
Entscheidungslogik.

Formatierungen im Dashboard beschraenken sich auf:

- Anzeigeverdichtung
- Einheiten-/Label-Aufbereitung
- Navigation zwischen Views
- visuelle Hervorhebung auffälliger Wetterlagen anhand vorhandener DWD-Werte
- badge-gestützte Schnellorientierung in Übersichts- und Detailbereichen

## Outputs / Side Effects

- keine Hardware-Steuerung
- keine Service-Calls
- keine Script-Ausführung

Das Dashboard ist reine Visualisierung und Navigation.

## Migration Note

Mit Version `2.0.0` wurde die bisherige lange Einzelansicht in drei klar getrennte
Views ueberfuehrt:

- `Aktuell`
- `Radar`
- `DWD Details`

Zusätzlich wurde der hardcodierte Demo-Platzhalter bei den Radar-Karten entfernt,
sodass wieder die echten Kamera-Feeds angezeigt werden.

Mit Version `2.1.0` kamen hinzu:

- Schnellnavigation in der Startansicht
- `Tagesfokus` als lesbare Kompaktzusammenfassung
- visuelle Zustandspriorisierung für Regen, Wind, Luft, Sicht und Sonne

Mit Version `2.2.0` kamen hinzu:

- dynamische `Warnlage` in der Startansicht
- Risiko-Scan mit Gauges für Regen, Böen und Sichtweite
- Badge-Orientierung in Übersicht, Radar und DWD-Detailsektionen
- textliche Radar-Einordnung für schnellere Niederschlagsbewertung

Mit der nachfolgenden Layout-Korrektur wurden ausserdem:

- `Einordnung`, Mehrtages-Trend und Temperaturverlauf in der Übersicht zu einem gemeinsamen Grid gebündelt
- die problematischen Zeit-Entitäten aus `Sonne und Astronomie` entfernt
- `Sonne und Astronomie` als sauberes Zweier-Layout aus Kennzahlen und Horizon-Karte geordnet

Mit der nachfolgenden Layout-Optimierung wurden ausserdem:

- der Trendbereich in `Aktuell` auf breitere Darstellung umgestellt
- `Sonne und Astronomie` als überbreite Vollsektion angelegt
- der missverständliche Wetterbericht-Block auf einen klaren DWD-Datenstand reduziert

Mit der aktuellen Detail-Anpassung wurden ausserdem:

- die Hinweistexte in `Aktuell` zu einer gemeinsamen breiten Zeile gebündelt
- `Einordnung und Trend` in `Aktuell` als Vollbreiten-Bereich statt als gequetschtes Teilraster ausgeführt
- `DWD-Details` in ruhige Vollbreiten-Blöcke mit konsistenten 2-Spalten-Paaren umgebaut
- `Temperatur` mit `Atmosphäre`, `Temperatur-Verlauf` mit `Wind` sowie `Niederschlag` mit `Strahlung` neu gruppiert
- `Astronomie` als eigene breite Sektion unterhalb der Messkarten angeordnet
- sichtbare UI-Bezeichnungen konsequent auf deutsche Schreibweise mit Umlauten umgestellt

## Troubleshooting

- Wenn Radar-Karten leer bleiben, Existenz und Verfügbarkeit von
  `camera.precipitation_2` und `camera.precipitation_3` pruefen.
- Wenn einzelne KPI-Karten `-` zeigen, zuerst die zugrunde liegenden DWD-Sensoren
  in Entwicklerwerkzeugen pruefen.
- Wenn der DWD-Datenstand leer oder veraltet wirkt, DWD-Integration und
  Stationsdaten auf Aktualisierung pruefen.
- Wenn Custom Cards nicht rendern, HACS-/Frontend-Ressourcen für
  `button-card`, `weather-chart-card` und `horizon-card` pruefen.

## Validierung

- YAML mit `D:\Codex\.venv\Scripts\yamllint.cmd`
- Dashboard-Datei gegen `configuration.yaml` referenziert
- Keine bestehenden `entity_id` umbenannt
- Keine neuen Hardware- oder Script-Pfade eingeführt
