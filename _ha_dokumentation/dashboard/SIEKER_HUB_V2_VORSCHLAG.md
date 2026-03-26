# Sieker Hub V2 Vorschlag

## Zweck

Dieses Dokument beschreibt einen wartbareren Zielzuschnitt fuer den gross
gewordenen `dashboards/sieker_hub.yaml`.

Annahme fuer die spaetere Umsetzung:

- die neue Variante muss parallel zum aktuellen `sieker_hub` laufen
- der bestehende Dashboard-Einstieg bleibt waehrend der Migration unveraendert
- es gibt keine `entity_id`-Umbenennungen
- die neue Variante bleibt auf denselben autoritativen Entitaeten, Skripten und
  sicheren Bedienpfaden

## Ausgangslage

Der aktuelle Hub ist funktional stark, aber als einzelne YAML-Datei zu gross
fuer entspannte Pflege.

Ist-Zustand in diesem Repository:

- `dashboards/sieker_hub.yaml` hat aktuell 4193 Zeilen
- der Hub enthaelt 22 Views und Subviews
- `button_card_templates` und alle Modul-Views liegen in derselben Datei
- die groessten zusammenhaengenden Fachbereiche sind:
  - Roborock: ca. 1414 Zeilen
  - Rolllaeden: ca. 529 Zeilen
  - Heizung: ca. 508 Zeilen
  - Wohnen inklusive Unterseiten: ca. 300 Zeilen

Besonders auffaellig:

- `hub_metric_card` wird sehr oft wiederverwendet
- `hub_nav_card`, `scene_action_card`, `info_panel_card` und
  `detail_text_card` tragen einen grossen Teil der wiederholten Struktur
- neue Aenderungen an einem Modul erfordern heute fast immer Arbeiten in einer
  grossen Monolith-Datei mit hohem Diff-Risiko

## Kernproblem

Der Hub ist nicht primar deshalb schwer wartbar, weil die Informationsarchitektur
falsch waere. Die eigentliche Last entsteht durch die Kopplung von:

- globalen Karten-Templates
- Navigation
- Home-View
- allen Fachmodulen
- allen Subviews
- allen kleinen Layout-Varianten

in genau einer Datei.

Das macht Aenderungen teuer:

- groessere Diffs
- hoehere Merge-Konflikt-Wahrscheinlichkeit
- schwierigeres Review
- schwerere Wiederverwendung von Kartenmustern
- hoeheres Risiko, bei Modul-Aenderungen versehentlich fremde Bereiche
  mitzubewegen

## Zielbild

Empfehlung: Den aktuellen Hub als `Legacy` stehen lassen und eine zweite,
modularisierte Variante daneben aufbauen.

Vorgeschlagene neue Dashboard-Definition:

- neues Dashboard in `configuration.yaml`, z. B. `sieker-hub-v2-dashboard`
- neue Datei `dashboards/sieker_hub_v2.yaml`
- bestehendes `dashboards/sieker_hub.yaml` bleibt waehrend der Migration aktiv

Wichtige Eigenschaft des Parallelbetriebs:

- dieselben View-Pfade koennen innerhalb des neuen Dashboards weiterverwendet
  werden, weil sich die Dashboards bereits ueber ihre Dashboard-ID trennen
- es ist deshalb kein kuenstlicher `-v2`-Suffix pro View noetig
- Links und Navigation muessen nur innerhalb der neuen Variante konsistent sein

## Empfohlene Zielstruktur

Die neue Variante sollte nicht wieder als eine grosse Einzeldatei wachsen.
Empfohlen ist ein Entry-Point plus modulare Quellfragmente.

### Dateischnitt

```text
dashboards/
  sieker_hub.yaml
  sieker_hub_v2.yaml
  sieker_hub_v2/
    shared/
      button_card_templates.yaml
    views/
      00_home.yaml
      10_raeume.yaml
      20_wohnen.yaml
      21_wohnen_beleuchtung.yaml
      22_wohnen_steckdosen.yaml
      23_wohnen_szenen.yaml
      30_heizung.yaml
      31_heizung_diagnose.yaml
      32_heizung_service.yaml
      33_heizung_tuning.yaml
      40_rollladen.yaml
      41_rollladen_diagnose.yaml
      42_rollladen_service.yaml
      43_rollladen_tuning.yaml
      50_steckdose_balkon.yaml
      51_steckdose_balkon_diagnose.yaml
      52_steckdose_balkon_tuning.yaml
      60_usv.yaml
      61_usv_diagnose.yaml
      70_waschmaschine.yaml
      80_roborock.yaml
      81_roborock_programme.yaml
      82_roborock_karte.yaml
      83_roborock_diagnose.yaml
      84_roborock_wochenplan.yaml
      85_roborock_wochenplan_mon.yaml
      86_roborock_wochenplan_die.yaml
      87_roborock_wochenplan_mit.yaml
      88_roborock_wochenplan_don.yaml
      89_roborock_wochenplan_fre.yaml
      90_roborock_wochenplan_sam.yaml
      91_roborock_wochenplan_son.yaml
      92_roborock_wartung.yaml
```

### Technische Zusammenfuehrung

Bevorzugte Variante:

- `dashboards/sieker_hub_v2.yaml` enthaelt nur Metadaten
- `button_card_templates` werden aus einer Shared-Datei geladen
- `views` werden aus einzelnen View-Dateien zusammengefuehrt

Moeglicher Einstieg:

```yaml
title: Sieker Hub Neu
button_card_templates: !include sieker_hub_v2/shared/button_card_templates.yaml
views: !include_dir_merge_list sieker_hub_v2/views
```

Falls sich der Dashboard-Loader in dieser HA-Instanz bei `views` nicht robust
mit `!include_dir_merge_list` verhaelt, sollte trotzdem an der fachlichen
Dateitrennung festgehalten werden. In diesem Fall waere ein generierter
`sieker_hub_v2.yaml` nur das Build-Artefakt, waehrend die Fragmente die
eigentliche Source of Truth bleiben.

## Architekturregeln fuer V2

Damit die neue Variante nicht wieder zum Monolith wird, sollten beim Aufbau
einige klare Regeln gelten.

### 1. Ein File pro View oder Subview

Jede Seite und jede Unterseite bekommt genau eine eigene Datei.

Vorteil:

- kleine Diffs
- klare Zustaendigkeit
- einfacheres Review

### 2. Shared-Datei nur fuer Darstellungsmuster

`shared/button_card_templates.yaml` darf enthalten:

- Stil-Templates
- generische Anzeige- und Navigationsmuster
- textliche Info-Panels ohne Modullogik

Nicht dort hinein:

- modulspezifische Entitaetslisten
- modulspezifische Navigation
- fachliche Sonderlogik einzelner Apps

### 3. Home bleibt kuratiert

`Home` soll nur leisten:

- Hausstatus
- Handlungsbedarf
- Einstieg in Fachmodule

Nicht mehr auf `Home`:

- lange Detailflaechen
- Wartungsdetails
- Tuning-Helfer
- tiefe Diagnose

### 4. Fachmodule bleiben die fachlichen Zentren

Die Views `Heizung`, `Rolllaeden`, `Roborock`, `Steckdose Balkon`, `USV`,
`Waschmaschine` und `Wohnen` bleiben erhalten, aber jede Einheit wird in ihrer
eigenen Datei gepflegt.

### 5. Subviews bleiben fachlich gruppiert

Die bisher gute Trennung aus:

- Uebersicht
- Diagnose
- Service
- Tuning

soll beibehalten werden. Wartbarkeit wird also nicht durch weniger Fachstruktur
erreicht, sondern durch bessere Dateigrenzen.

## Prioritaet fuer die spaetere Umsetzung

Fuer den groessten Wartbarkeitsgewinn zuerst die grossen und haeufig
veraenderungsnahen Bereiche auslagern.

Empfohlene Reihenfolge:

1. Roborock
2. Rolllaeden
3. Heizung
4. Wohnen
5. Home und Raeume
6. kleinere Geraetemodule wie USV und Waschmaschine

Warum diese Reihenfolge:

- Roborock ist der groesste Block und enthaelt viele Subviews
- Rolllaeden und Heizung sind fachlich wichtig und bereits stark gegliedert
- Wohnen ist ein guter Test fuer wiederkehrende UI-Muster
- kleine Geraetemodule liefern zum Schluss schnelle Restmigration

## Vorschlag fuer die Parallelmigration

### Phase 0

Nur Struktur vorbereiten:

- neues Dashboard `sieker-hub-v2-dashboard` in `configuration.yaml` anlegen
- neue Datei `dashboards/sieker_hub_v2.yaml`
- neue Fragment-Struktur unter `dashboards/sieker_hub_v2/`
- bestehendes `sieker_hub` nicht aendern

### Phase 1

Shared-Basis aufbauen:

- zentrale `button_card_templates`
- wiederkehrende Info- und Navigationsmuster in V2 vereinheitlichen
- nur ein minimales `Home` mit wenigen Navigationskarten anlegen

### Phase 2

Module nacheinander migrieren:

- zuerst Roborock
- danach Rolllaeden und Heizung
- dann Wohnen, Raeume und kleinere Geraete

### Phase 3

Vergleichsbetrieb:

- alter Hub bleibt produktiv nutzbar
- neuer Hub wird parallel im Alltag gegengetestet
- Pfad-, Karten- und Bedienlogik werden iterativ nachgezogen

### Phase 4

Spaetere Entscheidung:

- entweder der neue Hub ersetzt den alten
- oder der alte Hub bleibt noch befristet als Rueckfalloption

Diese Entscheidung sollte erst nach einer realen Alltagsphase fallen.

## Konkrete Umsetzungsempfehlung

Wenn wir das wirklich bauen, wuerde ich nicht mit einem Komplett-Neudesign
starten, sondern mit einer strukturellen Spiegelung des bestehenden Hubs.

Das bedeutet:

- gleiche fachliche Navigation
- gleiche sicheren Script-Entrypoints
- gleiche Entitaeten
- gleicher Bedienzweck pro Subview
- aber neue Dateigrenzen und klarerer Pflegezuschnitt

Erst danach sollte ueber inhaltliche UI-Vereinfachung entschieden werden.

So vermeiden wir, dass Parallelbetrieb und Redesign gleichzeitig zu viele
Aenderungsachsen aufmachen.

## Was dadurch besser wartbar wird

Der Vorschlag verbessert Wartbarkeit an mehreren Stellen:

- Modul-Aenderungen landen in kleinen, klar zuordenbaren Dateien
- Shared-Templates sind zentral statt implizit ueber den Monolith verteilt
- Review und Fehlersuche werden deutlich leichter
- parallele Arbeit an verschiedenen Modulen wird realistischer
- ein defektes Subview laesst sich schneller eingrenzen
- neue Modul-Subviews koennen additiv ergaenzt werden, ohne die ganze
  Dashboard-Datei neu zu sortieren

## Abhaengigkeiten

Fuer V2 bleiben die bereits produktiv genutzten Dashboard-Bausteine relevant:

- `button-card`
- `Bubble Card`, falls spaeter fuer Verdichtung genutzt
- `card-mod`, falls bestehende Kartenstile darauf beruhen
- `Xiaomi Vacuum Map Card` fuer Roborock

Die neue Variante sollte bewusst auf demselben HACS-Bestand aufbauen und keine
stillschweigende Rueckmigration auf Standardkarten erzwingen.

## Inputs und Parameter

Die V2-Struktur basiert weiterhin auf:

- bestehenden Sensoren, Helfern und Schaltern
- bestehenden sicheren Skript-Einstiegen
- bestehenden Modulpfaden und Bedienflussen

Neue Eingaben sind fuer den Fachbetrieb nicht notwendig. Die Aenderung ist
primar eine Struktur- und Wartbarkeitsmassnahme.

## Outputs und Side Effects

Erwartete Outputs:

- zusaetzlicher Dashboard-Einstieg fuer die V2-Variante
- modularisierte Dashboard-Dateien
- kleinere Diffs bei spaeteren Aenderungen

Bewusste Side Effects:

- kurzzeitig zwei nahezu gleichartige Hubs im System
- zunaechst etwas mehr Dateien, dafuer deutlich bessere lokale Pflege

## Troubleshooting

Wenn die spaetere Umsetzung stockt, zuerst diese Punkte pruefen:

- laden die verwendeten Lovelace-Resources fuer alle Custom Cards korrekt
- funktioniert die YAML-Include-Strategie im gewaehlten Dashboard-Aufbau
- bleiben alle `navigation_path`-Verweise innerhalb von V2 konsistent
- werden nur sichere Skripte und autoritative Entitaeten angesprochen
- ist die Home-Seite wirklich kuratiert oder waechst sie erneut zum Sammelplatz

## Validierungscheckliste fuer die spaetere Umsetzung

- `configuration.yaml` enthaelt alten und neuen Dashboard-Einstieg parallel
- alter `sieker_hub` bleibt unveraendert nutzbar
- keine `entity_id` wurde umbenannt
- alle V2-Subview-Links oeffnen innerhalb des neuen Dashboards korrekt
- verwendete HACS-Karten sind weiter verfuegbar
- YAML lintet sauber
- Modul-Doku wird aktualisiert, sobald echte Navigation oder Bedienfluesse
  umgesetzt werden

## Entscheidungsempfehlung

Mein Vorschlag ist deshalb nicht "weniger Dashboard", sondern:

- gleicher fachlicher Zuschnitt
- klarere Dateigrenzen
- zweiter Dashboard-Einstieg fuer Parallelbetrieb
- Migration in kleinen Modulpaketen statt Big-Bang

Das ist aus meiner Sicht der risikoaermste Weg zu deutlich besserer
Wartbarkeit.
