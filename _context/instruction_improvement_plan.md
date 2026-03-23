# Instruction Improvement Plan

## Zweck

Dieser Plan beschreibt, wie die zuvor identifizierten Verbesserungen 1 bis 6
kontrolliert und ohne Regel-Drift umgesetzt werden koennen.

## Status

Bereits erledigt:

- modulbezogene Regeln fuer Roborock, Heating und Shutters
- Dokumentationspflicht fuer dokumentierte Module
- Environment-, Repo-vs-Runtime- und Deployment-Kontext
- Dashboard-Grundregeln inklusive kompakter Subviews
- Startvorlagen unter `D:\Codex\_codex_vorlagen\`
- diese Uebersichtsdatei `instruction_map.md`
- Verweise auf `instruction_map.md` in den Einstiegspunkten
- `rule_change_checklist.md` fuer die Gegenpruefung bei Regelaenderungen

Noch weiter ausbaubar:

- Redundanzabbau
- Review-Rhythmus fuer Regelkonsistenz
- weitere spezialisierte Vorlagen

Phase-1-Status:

- Phase 1 ist umgesetzt.

## 1. Redundanz reduzieren

### Ziel

`AGENTS.md` soll die globale Einstiegsebene bleiben, waehrend `_context`
die tieferen Detailregeln traegt.

### Vorgehen

1. Regelthemen inventarisieren:
   - Pfade
   - Doku-Pflicht
   - Dashboard-Regeln
   - Deployment
   - Architektur
2. Fuer jedes Thema die autoritative Hauptdatei festlegen.
3. Doppelte Detailregeln in anderen Dateien auf Kurzverweise reduzieren.
4. Nur solche Redundanz stehen lassen, die absichtlich als Sicherheitsnetz dient.

### Konkrete Umsetzung

- `AGENTS.md`: nur globale Kurzfassung + Verweise
- `_context/project_rules.md`: nur repo-weite Umsetzungsregeln
- `_context/architecture.md`: nur Architektur-/Dashboard-Schichtregeln
- `_context/deployment.md`: nur Live-/Deploy-/Aktivierungsregeln

### Erfolgskriterium

Jedes Thema hat genau eine offensichtliche Hauptdatei.

## 2. Meta-Uebersicht pflegen

### Ziel

Neue Threads sollen schnell erkennen koennen, welche Datei wann relevant ist.

### Vorgehen

1. `instruction_map.md` als zentrale Landkarte pflegen.
2. In `README_AGENT.md` und `AGENTS.md` knapp auf diese Landkarte verweisen.
3. Bei neuen Modulregeln oder neuen Doku-Ordnern die Map im gleichen Task aktualisieren.

### Erfolgskriterium

Ein neuer Thread kann mit einer einzigen Datei den Rest des Regelwerks finden.

## 3. Regel-Konflikte aktiv verhindern

### Ziel

Widersprueche wie `config/packages/...` vs `packages/...` sollen frueh erkannt werden.

### Vorgehen

1. Bei jeder Aenderung an `AGENTS.md` angrenzende `_context`-Dateien kurz gegenlesen.
2. Bei jeder Aenderung an einer `_context`-Regel pruefen:
   - beruehrt das `AGENTS.md`?
   - beruehrt das Modul-Doku?
   - beruehrt das eine Startvorlage?
3. Optional spaeter:
   - kleine Checkliste in `_codex_vorlagen` fuer Regelpflege

### Erfolgskriterium

Keine gleichzeitigen Widersprueche in zentralen Pfad-, Doku- oder Deploy-Regeln.

## 4. Vorlagen weiter typisieren

### Ziel

Wiederkehrende Aufgaben sollen mit weniger Erklaerungsaufwand gestartet werden koennen.

### Priorisierte neue Vorlagen

1. `startvorlage_code_review.md`
2. `startvorlage_architektur_aenderung.md`
3. `startvorlage_dokumentation_aktualisieren.md`
4. `startvorlage_dashboard_bugfix.md`

### Vorgehen

1. Nur Vorlagen anlegen, die real wiederkehrend gebraucht werden.
2. Namen einheitlich halten.
3. Jede neue Vorlage in `_codex_vorlagen/README.md` aufnehmen.

### Erfolgskriterium

Haeufige Aufgabentypen lassen sich mit einer vorhandenen Vorlage starten.

## 5. Weitere Module nur bei Bedarf dokumentieren

### Ziel

Regelwerk und Doku sollen nicht schneller wachsen als ihr Nutzen.

### Ausloeser fuer neue Moduldateien / Doku

- Modul wird wiederholt geaendert
- Modul hat mehrere Schichten oder Sonderlogik
- Bedienpfad / Dashboard ist komplex
- wiederkehrende Bugs oder Missverstaendnisse treten auf

### Vorgehen

1. Vor einer neuen Modul-Doku kurz Nutzen gegen Pflegeaufwand abwaegen.
2. Wenn dokumentiert wird:
   - Modulregel in `_context/modules/`
   - technische Doku in `_ha_dokumentation/`
   - ggf. Diagramm

### Erfolgskriterium

Nur Module mit echtem Komplexitaets- oder Wiederholungswert bekommen eigene Regel-/Dokuebenen.

## 6. Instruktionspflege als eigenen Prozess etablieren

### Ziel

Regeln, Doku und Vorlagen sollen bewusst mit dem Projekt mitwachsen.

### Vorgehen

1. Bei groesseren Aenderungen immer kurz pruefen:
   - braucht `_ha_dokumentation` ein Update?
   - braucht `_context/modules/...` ein Update?
   - braucht `_codex_vorlagen` eine neue oder angepasste Vorlage?
2. Bei Architektur- oder Deploy-Aenderungen:
   - `AGENTS.md`
   - `deployment.md`
   - `architecture.md`
   gegeneinander pruefen
3. Optional spaeter:
   - quartalsweise oder bei groesseren Refactors Regel-Review

### Erfolgskriterium

Regeln und Projektrealitaet driften nicht auseinander.

## Empfohlene Umsetzungsreihenfolge

### Phase 1

- `instruction_map.md` pflegen
- Verweise darauf in Einstiegspunkten setzen
- bei Regel-Aenderungen konsequent Gegenpruefung machen

### Phase 2

- Redundanz schrittweise reduzieren
- neue Vorlagen fuer haeufige Tasks ergaenzen

### Phase 3

- nur bei Bedarf weitere Module dokumentieren
- kleinen Review-Rhythmus fuer Regelpflege etablieren

## Praktische Arbeitsregel

Nicht moeglichst viele Regeln ergaenzen, sondern:

- nur reale Wiederholungsprobleme dokumentieren
- klare Hauptdatei je Thema behalten
- Doku, Regeln und Vorlagen zusammen pflegen
