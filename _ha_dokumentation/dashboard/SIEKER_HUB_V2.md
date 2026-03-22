# Sieker Hub v2

## Zweck

`dashboards/sieker_hub_v2.yaml` ist die best-practice-orientierte Weiterentwicklung von
`dashboards/sieker_hub.yaml` bei unverändertem Bestand. `v1` bleibt als stabile Referenz bestehen,
`v2` trennt Startseite, Räume und Fachmodule konsequenter.

## Navigationslogik

- `Home` ist ein Leitstand mit Hausstatus, Abweichungen und Fachmodulen.
- `Räume` ist ein eigener Top-Level-View für Klima- und Umgebungsdaten.
- Geräte, die keine Raumdaten darstellen, werden als Modul geführt.

## Wichtige Unterschiede zu v1

- Keine Raum-Vorschau mehr auf `Home`.
- `Räume` ist bewusst nicht Teil der Fachmodule.
- Die frühere Keller-Waschmaschinenansicht wurde als eigenes Modul `Waschmaschine` herausgelöst.

## Fachmodule in v2

- Heizung
- Rollläden
- Steckdose Balkon
- USV
- Waschmaschine
- Roborock

## Räume-View

Der View `Räume` enthält nur Raum- und Umgebungsdaten:

- Küche
- Wohnzimmer
- Schlafzimmer
- Bad
- Flur
- Gästebad
- Gästezimmer
- Balkon

Die Waschmaschine gehört bewusst nicht mehr in diesen View.

## Waschmaschinen-Modul

Das Modul `Waschmaschine` bündelt die bisherige Keller-Ansicht als Geräteansicht.

### Sichtbare Entitäten

- `sensor.waschmaschine_maschinenzustand`
- `sensor.waschmaschine_fertigstellungszeit`
- `switch.waschmaschine_bubble_soak`
- `select.waschmaschine_dosiermenge_fur_waschmittel`
- `select.waschmaschine_schleuderstufe`
- `number.waschmaschine_spulgange`

## Validierung

- YAML mit `D:\Codex\.venv\Scripts\yamllint.cmd`
- Navigation gegen `configuration.yaml` geprüft
- Keine bestehenden `entity_id` umbenannt
