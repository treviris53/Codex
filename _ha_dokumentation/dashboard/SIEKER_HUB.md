# Sieker Hub

## Zweck

`dashboards/sieker_hub.yaml` ist der aktuelle operator-orientierte Hub. Er trennt
Startseite, Wohnen, Räume und Fachmodule klar nach Bedienzweck.

## Navigationslogik

- `Home` ist ein Leitstand mit Hausstatus, Handlungsbedarf und Fachmodulen.
- `Wohnen` bündelt die manuelle Alltagssteuerung für Beleuchtung, Steckdosen und Szenen.
- `Räume` ist ein eigener Top-Level-View für Klima- und Umgebungsdaten.
- Geräte, die keine Raumdaten darstellen, werden als Modul geführt.

## Informationsarchitektur

- `Home` ist ein Leitstand ohne vollständige Raumvorschau und ohne Alltagsbedienung.
- `Wohnen` trennt manuelle Wohnfunktionen bewusst von Diagnose- und Technikmodulen.
- `Räume` ist bewusst nicht Teil der Fachmodule.
- Die frühere Keller-Waschmaschinenansicht wurde als eigenes Modul `Waschmaschine` herausgelöst.

## Fachmodule

- Wohnen
- Heizung
- Rollläden
- Steckdose Balkon
- USV
- Waschmaschine
- Roborock

## Wohnen-Modul

Das Modul `Wohnen` bündelt die früher auf der Startseite verteilte manuelle Bedienung.

### Unterseiten

- `Beleuchtung` für manuell schaltbare Lichter nach Räumen
- `Steckdosen` für allgemeine, bewusst manuell bediente Steckdosen inklusive Leistung, Energie und Kindersicherung
- `Szenen` für die manuellen Heizungsszenen 17, 19 und 21 Grad

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
