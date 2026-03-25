# Dashboard Rules

## Zweck

Diese Datei enthaelt die arbeitspraktischen Regeln fuer Dashboard-Aenderungen
in diesem Repository.

Sie ergaenzt:

- `D:\Codex\_context\architecture.md` fuer Architektur und Schichttrennung
- `D:\Codex\_context\hacs_inventory.md` fuer Dashboard-relevante HACS-Module

## Gestaltungsgrundsaetze

- Bevorzuge klare, kompakte Dashboards mit logischer Informationsarchitektur.
- Bevorzuge Subviews / Untermenues statt langer Einzelseiten.
- Vermeide seitenlanges vertikales Scrollen, wenn Inhalte sinnvoll in fokussierte Unterseiten getrennt werden koennen.
- Trenne Bedienung, Status, Diagnose, Service und Tuning sichtbar voneinander.
- Erhalte schnelle Orientierung: wichtige Aktionen und Kernstatus sollen ohne langes Scrollen sichtbar sein.

## Strukturelle Regeln

- Dashboards sind Visualisierung und sicherer Einstiegspunkt, keine zweite Entscheidungslogik.
- Dashboards sollen autoritative Paketlogik konsumieren, nicht nachbauen.
- Bevorzuge bestehende sichere Script- und Service-Einstiege.
- Erhalte Navigation, Subviews und operator-facing Struktur, solange kein bewusstes Redesign angefragt ist.
- Fuehre groessere Dashboard-Umbauten moeglichst als strukturierte Subview-Verbesserung statt als unkontrolliertes Seitenwachstum durch.

## Entwicklungsrelevante HACS-Module

Die folgenden installierten HACS-Module sind fuer Dashboard-Arbeit besonders relevant:

- `Bubble Card`
- `button-card`
- `Xiaomi Vacuum Map Card`
- `auto-entities`
- `card-mod`
- `Clock Weather Card`
- `Horizon Card`
- `Weather Chart Card`
- `card-tools`
- `search-card`
- `iOS Theme - Based on the system-wide light and dark mode UI`

## Arbeitsregeln fuer HACS-Karten

- Vor Dashboard-Refactors pruefen, welche Karten oder visuellen Muster bereits produktiv genutzt werden.
- Bereits installierte und etablierte HACS-Karten bevorzugt wiederverwenden, wenn sie das bestehende UX-Muster tragen.
- Die bewusste weitere Nutzung von Custom Cards ist in diesem Repository erlaubt und gewuenscht, wenn sie Bedienfluss, Lesbarkeit oder Fachfunktion tragen.
- Keine produktiv genutzte Custom Card stillschweigend entfernen, wenn dadurch Bedienfluss, Lesbarkeit oder Funktionsumfang verloren geht.
- Wenn eine Dashboard-Datei HACS-Karten nutzt, diese Abhaengigkeit in der Aufgabenanalyse und bei groesseren Redesigns auch in der Doku mitberuecksichtigen.
- Globale Lovelace-Resource-Umbauten, insbesondere `resource_mode: yaml` oder ein zentraler `resources:`-Block in `configuration.yaml`, gelten als high-risk und duerfen nur mit ausdruecklicher Migration/Validierung geaendert werden.

## Wann diese Datei lesen?

- vor Dashboard-Redesigns
- vor Dashboard-Bugfixes
- vor groesseren UI-/Subview-Umbauten
- wenn unklar ist, welche installierten HACS-Karten bereits als Bausteine verfuegbar sind
