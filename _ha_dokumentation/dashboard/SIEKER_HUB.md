# Sieker Hub

## Zweck

`dashboards/sieker_hub.yaml` ist der aktuelle operator-orientierte Hub. Er trennt
Startseite, Wohnen, Räume und Fachmodule klar nach Bedienzweck.

Der Hub nutzt bewusst produktive Custom Cards dort, wo sie Navigation,
Verdichtung oder Spezialfunktionen besser tragen als reine Standardkarten.

## Navigationslogik

- `Home` ist ein Leitstand mit verdichtetem Hausstatus, Handlungsbedarf und Fachmodulen.
- `Wohnen` bündelt die manuelle Alltagssteuerung für Beleuchtung, Steckdosen und Szenen.
- `Räume` ist ein eigener Top-Level-View für Klima- und Umgebungsdaten.
- Geräte, die keine Raumdaten darstellen, werden als Modul geführt.

## Informationsarchitektur

- `Home` ist ein Leitstand ohne vollständige Raumvorschau und ohne Alltagsbedienung.
- `Home` nutzt kompakte Status-, Alert- und Navigationskarten statt klassischer Entity-Listen, bleibt aber auf denselben autoritativen Entitäten.
- `Wohnen` trennt manuelle Wohnfunktionen bewusst von Diagnose- und Technikmodulen.
- `Räume` ist bewusst nicht Teil der Fachmodule.
- `Räume` nutzt kuratierte Klima- und Kontextkarten mit bewusst gekürzten, gut lesbaren Raumlabels.
- Die frühere Keller-Waschmaschinenansicht wurde als eigenes Modul `Waschmaschine` herausgelöst.

## Fachmodule

- Wohnen
- Heizung
- Rollläden
- Steckdose Balkon
- USV
- Waschmaschine
- Roborock

Kleine Geraetemodule wie `USV` und `Waschmaschine` folgen derselben kompakten
Kartensprache wie `Home`, `Räume` und `Wohnen`, bleiben fachlich aber auf
Status, Bedienung und Einordnung begrenzt.

## Heizung-Modul

Das Modul `Heizung` bleibt das fachliche Bedienzentrum fuer Sollprofil,
Eingangslage, Service und Tuning der Heating-App.

Der Top-Level-View ist in vier Bloecke gegliedert:

- `Betrieb` fuer Sollprofil, aktives Profil, letzte Anwendung, letzte Entscheidung, Override und Urlaub
- `Eingangslage` fuer Anwesenheit, Winterbetrieb, Prognose und Saison
- `Untermenüs` fuer Diagnose, Service und Tuning plus Kurz-Historie
- `Einordnung` als Kontextkarte zur Trennung zwischen Uebersicht und direkter Parameterpflege

Das Tuning-Subview bleibt bewusst direkt editierbar ueber klassische Helper-
Listen, damit Modus und Schwellwerte ohne weiteren Tiefensprung geaendert
werden koennen.

`Diagnose` ist als Leseflaeche fuer Sollprofil, Gruende, Entscheidungskette und
Rohwerte verdichtet. `Service` bleibt der schnelle Safe-Einstieg fuer die
autoritative Profilanwendung, ohne Modus- oder Schwellwertpflege zu verstecken.

## Wohnen-Modul

Das Modul `Wohnen` bündelt die früher auf der Startseite verteilte manuelle Bedienung.

Der Top-Level-View ist als kompakte Alltagsoberfläche gedacht:

- `Schnellzugriff` als kompakte Toggle-Karten für die wichtigsten manuellen Wohnaktionen
- `Untermenüs` als visuell vereinheitlichte Einstiegskarten für Beleuchtung, Steckdosen und Szenen
- `Einordnung` als kurze operator-orientierte Kontextkarte

### Unterseiten

- `Beleuchtung` für manuell schaltbare Lichter nach Räumen
- `Steckdosen` für allgemeine, bewusst manuell bediente Steckdosen inklusive Leistung, Energie und Kindersicherung
- `Szenen` für die manuellen Heizungsszenen 17, 19 und 21 Grad

Die Unterseite `Steckdosen` bleibt bewusst direkt editierbar ueber klassische
Entity-Listen, damit Schalten und Kindersicherung nicht erst ueber `more-info`
oder eine weitere Ebene erreicht werden muessen.

## Räume-View

Der View `Räume` enthält nur Raum- und Umgebungsdaten:

- Küche
- Wohnen
- Schlafen
- Bad
- Flur
- Gästebad
- Gäste
- Balkon

Die Waschmaschine gehört bewusst nicht mehr in diesen View.

## USV-Modul

Das Modul `USV` bündelt den produktiven Betriebszustand der Eaton-USV als
kompakten Geräte-View.

Der View ist in drei Bloecke gegliedert:

- `Übersicht` mit Akku-Gauge sowie kompakten Karten für Laufzeit, Last und Leistung
- `Ausgang` für Spannung, Piepser und Shutdown-Timer
- `Untermenüs` für den Diagnose-Einstieg

Die detaillierten Rohwerte bleiben im Diagnose-Subview.

Das Diagnose-Subview ist ebenfalls in kompakte Karten gegliedert und trennt
`Rohstatus` von `Elektrik`, statt die Werte nur als lange Entity-Liste zu zeigen.

## Steckdose-Balkon-Modul

Das Modul `Steckdose Balkon` bleibt bewusst ein eigenes Fachmodul, weil dort
Saison-, Zeitfenster- und Helligkeitslogik zusammenlaufen.

Der Top-Level-View ist in fünf Bloecke gegliedert:

- `Übersicht` für Saisonstatus, Steckdose, Dunkelheit und Debug-Zustand
- `Verlauf` für letzte Aktion und Zeitpunkt
- `Zeitfenster` für Morgen-/Abendlogik inklusive festem Morgenaus
- `Untermenüs` für Diagnose und Tuning
- `Einordnung` als kurze Kontextkarte zur Abgrenzung gegenüber allgemeinen Wohn-Steckdosen

Das Diagnose-Subview zeigt die Debug-Lage als kompakte Karten plus Historie.
Das Tuning-Subview bleibt bewusst direkt editierbar ueber klassische Helper-
Listen, damit Zeitfenster und Schwellen nicht erst eine weitere Ebene tiefer
geaendert werden muessen.

## Waschmaschinen-Modul

Das Modul `Waschmaschine` bündelt die bisherige Keller-Ansicht als Geräteansicht.

Der View ist in drei Bloecke gegliedert:

- `Übersicht` für Maschinenzustand und Fertig
- `Einstellungen` für Bubble Soak, Waschmittel, Schleudern und Spülgänge
- `Einordnung` als kurze Kontextkarte zur bewussten Trennung von Raum- und Geräteansicht

Der Block `Einstellungen` bleibt bewusst direkt bedienbar ueber Tiles, damit
die Geraeteparameter ohne weiteren Tiefensprung geaendert werden koennen.

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
- Bei Dashboard-Problemen immer auch globale Lovelace-Resource-Aenderungen in `configuration.yaml` pruefen; ein fehlerhafter globaler Resource-Umbau kann mehrere Subviews gleichzeitig brechen.
