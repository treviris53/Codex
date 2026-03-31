# Sieker Hub

## Zweck

`dashboards/sieker_hub.yaml` ist der aktuelle operator-orientierte Hub. Er trennt
Startseite, Wohnen, Räume und Fachmodule klar nach Bedienzweck.

Der Hub nutzt bewusst produktive Custom Cards dort, wo sie Navigation,
Verdichtung oder Spezialfunktionen besser tragen als reine Standardkarten.

## V2-Grundgerüst

Parallel zum bestehenden Hub existiert jetzt auch ein V2-Grundgeruest:

- Dashboard-Einstieg: `sieker-hub-v2-dashboard` in `configuration.yaml`
- Entry-Point: `dashboards/sieker_hub_v2.yaml`
- modulare Quellen unter `dashboards/sieker_hub_v2/shared/` und
  `dashboards/sieker_hub_v2/views/`

Das V2-Dashboard ist als parallele, modulare Variante des aktuellen Hubs
aufgebaut. Der Fokus lag zunaechst auf der risikoarmen Migration der
bestehenden Fachmodule in einzelne View-Dateien.

Stand jetzt:

- der `Home`-View ist in V2 als verdichteter Leitstand aus dem bestehenden Hub
  gespiegelt
- das Roborock-Modul ist in V2 bereits funktional aus dem bestehenden Hub
  gespiegelt
- das Heating-Modul ist in V2 bereits funktional aus dem bestehenden Hub
  gespiegelt
- das Rollläden-Modul ist in V2 bereits funktional aus dem bestehenden Hub
  gespiegelt
- die restlichen Modul- und Alltags-Views `Räume`, `Wohnen`, `Steckdose Balkon`,
  `USV`, `QNAP` und `Waschmaschine` sind ebenfalls funktional in V2 gespiegelt
- die Roborock-Views leben in eigenen Dateien unter
  `dashboards/sieker_hub_v2/views/80_...` bis `92_...`
- die Heating-Views leben in eigenen Dateien unter
  `dashboards/sieker_hub_v2/views/30_...` bis `33_...`
- die Rollläden-Views leben in eigenen Dateien unter
  `dashboards/sieker_hub_v2/views/40_...` bis `43_...`
- `Räume`, `Wohnen`, `Steckdose Balkon`, `USV`, `QNAP` und `Waschmaschine`
  leben in eigenen Dateien unter `10_...`, `20_...`, `50_...`, `60_...`,
  `62_...` bis `63_...` und `70_...`

## Navigationslogik

- `Home` ist ein Leitstand mit verdichtetem Hausstatus, Handlungsbedarf und Fachmodulen.
- `Wohnen` bündelt die manuelle Alltagssteuerung für Beleuchtung, Steckdosen und Szenen.
- `Räume` ist ein eigener Top-Level-View für Klima- und Umgebungsdaten.
- Geräte, die keine Raumdaten darstellen, werden als Modul geführt.

## Informationsarchitektur

- `Home` ist ein Leitstand ohne vollständige Raumvorschau und ohne Alltagsbedienung.
- `Home` nutzt kompakte Status-, Alert- und Navigationskarten statt klassischer Entity-Listen, bleibt aber auf denselben autoritativen Entitäten.
- `Home` spiegelt kritische Roborock-Wartung direkt im Roborock-Statusbutton, ohne die Wartungslogik im Dashboard nachzubauen.
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
- QNAP
- Waschmaschine
- Roborock

Kleine Geraetemodule wie `USV`, `QNAP` und `Waschmaschine` folgen derselben
kompakten Kartensprache wie `Home`, `Räume` und `Wohnen`, bleiben fachlich
aber auf Status, Diagnose und Einordnung begrenzt.

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

## Rollläden-Modul

Das Modul `Rollläden` bleibt das fachliche Bedienzentrum fuer Zeitfenster,
Zielpositionen, Overrides und Beschattung.

Der Top-Level-View ist in fünf Bloecke gegliedert:

- `Status` fuer Automatik, Day-Window, Open-/Close-Zeiten und Override-Zustaende
- `Zielbild` fuer Ost-, West- und Nord-Zielpositionen plus Debug-Sensoren
- `Untermenüs` fuer Diagnose, Service und Tuning
- `Einflussfaktoren` fuer Steckdose, Beschattung und Tuerkontakt
- `Einordnung` als Kontextkarte zur Trennung von Uebersicht, Service und Tuning

Das Tuning-Subview bleibt bewusst direkt editierbar ueber klassische Helper-
Listen, damit Zeitregeln und Beschattungsparameter ohne weiteren Tiefensprung
geaendert werden koennen.

`Diagnose` ist als Leseflaeche fuer Day-Window, Zeitfenster und thematisch
gruppierte Debug-Gruende verdichtet. `Service` bleibt funktional
unveraendert: Safe-Einstiege, manuelle Notfallbedienung und Sammelbedienung
bleiben direkt erreichbar.

## Wohnen-Modul

Das Modul `Wohnen` bündelt die früher auf der Startseite verteilte manuelle Bedienung.

Der Top-Level-View ist als kompakte Alltagsoberfläche gedacht:

- `Schnellzugriff` als kompakte Toggle-Karten für die wichtigsten manuellen Wohnaktionen
- `Untermenüs` als visuell vereinheitlichte Einstiegskarten für Beleuchtung, Steckdosen und Szenen
- `Einordnung` als kurze operator-orientierte Kontextkarte

### Unterseiten

- `Beleuchtung` für manuell schaltbare Lichter nach Räumen
- `Steckdosen` für allgemeine, bewusst manuell bediente Steckdosen inklusive Leistung, Energie und Kindersicherung
- `Szenen` für direkte manuelle Temperaturszenen der Heizung und Bäder

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

## QNAP-Modul

Das Modul `QNAP` bündelt den produktiven Betriebszustand des NAS als
kompakten Geräte-View mit Fokus auf Systemgesundheit und erkennbare Probleme.

Der Top-Level-View ist in vier Bloecke gegliedert:

- `Übersicht` für Status, Laufzeit, CPU-/RAM-Last und Temperaturbild
- `Speicher & Netz` für die wichtigsten Volume-Auslastungen sowie Link- und
  Fehlerlage der beiden Netzwerkports
- `Untermenüs` für den Diagnose-Einstieg
- `Einordnung` als kurze Kontextkarte zur Trennung von verdichtetem Status und
  Detaildiagnose

Das Diagnose-Subview ist thematisch in `System`, `Laufwerke`, `Volumes` und
`Netzwerk` getrennt. Dadurch bleiben SMART-Status, SSD-/Laufwerkstemperaturen,
aktive Volume-Nutzungen und freie Speicherwerte lesbar, ohne den Top-Level-View
mit Rohwerten zu überladen.

Zusätzlich wird der QNAP-Zustand im `Home`-View als verdichtete Statuskarte
gespiegelt. Kritische Hinweise werden dort bewusst nur verdichtet angezeigt,
zum Beispiel Link-Abweichungen, Paketfehler oder hohe Belegung wichtiger
Volumes.
Kritische Sensorzustände werden im Modul zusätzlich farblich markiert, damit
Temperatur-, SMART-, Link-, Fehler- und Belegungsprobleme direkt aus dem
Kartenbild erkennbar sind.

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

## Roborock-Modul

Das Modul `Roborock` bleibt das fachliche Bedienzentrum fuer sichere
Einzelprogramme, Wochenplan, Kartenansicht, Diagnose und Wartung.

Der Top-Level-View ist in vier Bloecke gegliedert:

- `Betrieb` fuer Status, Batterie, Busy- und Blocked-Zustand
- `Letzte Ausführung` fuer Slot, Job, Programmfolge und aktuellen Raum
- `Hinweise` fuer Fehlertext und kurze fachliche Einordnung
- `Untermenüs` fuer Programme, Karte, Diagnose, Wochenplan und Wartung

Die Unterseite `Programme` nutzt weiter ausschließlich sichere Starts ueber
`script.roborock_run_named_program`.

Die Unterseite `Karte` bleibt bewusst nahe an der bestehenden
`xiaomi-vacuum-map-card`, weil dort Spezialfunktion wichtiger ist als reine
Designvereinheitlichung.

`Diagnose` ist als Leseflaeche fuer Betrieb, Verlauf und Jobstart verdichtet.
`Wochenplan` zeigt einen kompakten globalen Schalter plus Wochentagskarten,
waehrend die einzelnen Tages-Subviews bewusst direkt editierbar bleiben.
`Wartung` zeigt Resets und Verbrauchsmaterial in derselben Kartensprache wie
die anderen modernisierten Module, ohne die Funktion zu aendern. Ein
kritischer Wartungszustand wird zusaetzlich im `Home`-View am
Roborock-Statusbutton gespiegelt.

## Validierung

- YAML mit `D:\Codex\.venv\Scripts\yamllint.cmd`
- Navigation gegen `configuration.yaml` geprüft
- Keine bestehenden `entity_id` umbenannt
- Bei Dashboard-Problemen immer auch globale Lovelace-Resource-Aenderungen in `configuration.yaml` pruefen; ein fehlerhafter globaler Resource-Umbau kann mehrere Subviews gleichzeitig brechen.
- Beobachtung aus der V2-Migration: Aenderungen an einzelnen View-Dateien unter `dashboards/sieker_hub_v2/views/` wurden im laufenden Betrieb nicht immer sofort uebernommen, obwohl die Dateien auf `W:\` korrekt deployt waren.
- Fuer `sieker_hub_v2.yaml` mit `!include_dir_merge_list` kann deshalb im Zweifel ein Home-Assistant-Core-Neustart noetig sein; beim monolithischen `sieker_hub.yaml` war das Verhalten direkter.
