# Wetter Dashboard

## Zweck

`dashboards/wetter_dashboard.yaml` ist das operator-orientierte Wetter-Dashboard
fuer DWD-Daten der Station Hamburg-Fuhlsbuettel.

Das Dashboard trennt:

- schnelle Wetterlage
- Radar-Lagebild
- tiefe DWD-Kennzahlen und Diagnose

Damit bleibt die Startansicht kompakt, waehrend Detaildaten und Diagnose nicht
mehr in einer langen Einzelansicht untergehen.

## Datenbasis

Autoritative Wetterquelle ist:

- `weather.hamburg_fu`

Verwendete DWD-Sensoren umfassen unter anderem:

- `sensor.hamburg_fu_wetterzustand`
- `sensor.hamburg_fu_wetterbericht`
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
- `sensor.hamburg_fu_zeit_messwerte`
- `sensor.hamburg_fu_zeit_vorhersagewerte`
- `sensor.hamburg_fu_vorhersagezeit_local`

Radar-Karten:

- `camera.precipitation_3` fuer 35 km
- `camera.precipitation_2` fuer 250 km

## Informationsarchitektur

### Aktuell

`Aktuell` ist die primäre Entscheidungsansicht.

Sie zeigt:

- Hero-Karte mit aktueller Temperatur, Wetterzustand und Tages-Spanne
- DWD-Wetterbericht
- kompaktes Schnellbild fuer Regen, Wind, Luft, Sicht und Sonne
- Stunden-Forecast fuer die naechsten Stunden
- Mehrtages-Trend plus Temperaturverlauf

### Radar

`Radar` ist das Niederschlags-Lagebild.

Sie zeigt:

- lokales Radar 35 km
- regionales Radar 250 km
- flankierende Niederschlags- und Sicht-Kennzahlen

### DWD Details

`DWD Details` ist die Fach- und Diagnoseansicht.

Sie trennt:

- Thermik
- Luft und Sicht
- Wind und Niederschlag
- Sonne und Astronomie

Damit bleibt die Startansicht frei von Rohdaten-Ueberladung.

## Bedienfluss

Empfohlener Ablauf:

1. `Aktuell` fuer schnelle Lageeinschaetzung nutzen.
2. Bei Niederschlagslage in `Radar` wechseln.
3. Bei Analyse oder Plausibilisierung in `DWD Details` wechseln.

## Abhaengigkeiten

- DWD Weather Integration fuer `weather.hamburg_fu`, DWD-Sensoren und Radar-Kameras
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

## Outputs / Side Effects

- keine Hardware-Steuerung
- keine Service-Calls
- keine Script-Ausfuehrung

Das Dashboard ist reine Visualisierung und Navigation.

## Migration Note

Mit Version `2.0.0` wurde die bisherige lange Einzelansicht in drei klar getrennte
Views ueberfuehrt:

- `Aktuell`
- `Radar`
- `DWD Details`

Zusaetzlich wurde der hardcodierte Demo-Platzhalter bei den Radar-Karten entfernt,
sodass wieder die echten Kamera-Feeds angezeigt werden.

## Troubleshooting

- Wenn Radar-Karten leer bleiben, Existenz und Verfuegbarkeit von
  `camera.precipitation_2` und `camera.precipitation_3` pruefen.
- Wenn einzelne KPI-Karten `-` zeigen, zuerst die zugrunde liegenden DWD-Sensoren
  in Entwicklerwerkzeugen pruefen.
- Wenn der Wetterbericht leer ist, DWD-Integration und Stationsdaten auf
  Aktualisierung pruefen.
- Wenn Custom Cards nicht rendern, HACS-/Frontend-Ressourcen fuer
  `button-card`, `weather-chart-card` und `horizon-card` pruefen.

## Validierung

- YAML mit `D:\Codex\.venv\Scripts\yamllint.cmd`
- Dashboard-Datei gegen `configuration.yaml` referenziert
- Keine bestehenden `entity_id` umbenannt
- Keine neuen Hardware- oder Script-Pfade eingefuehrt
