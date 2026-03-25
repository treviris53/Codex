# HACS Inventory

## Zweck

Diese Datei dokumentiert die relevanten HACS-Erweiterungen fuer dieses Repository.
Sie ist keine Vollersatz-Doku fuer HACS selbst, sondern eine Arbeitsgrundlage fuer:

- Dashboard-Aenderungen
- custom integrations
- Abhaengigkeiten bei Modulen
- Entwicklungs- und Review-Kontext

Stand:
- basiert auf dem vom Nutzer bereitgestellten HACS-Bestand
- ohne Versionsbindung

## Grundregel

- HACS ist installiert und produktiv genutzt.
- Custom Integrations, Dashboard-Karten und Themes duerfen nicht stillschweigend entfernt, ersetzt oder ignoriert werden.
- Bei Dashboard-, Integrations- oder Modul-Aenderungen muessen relevante HACS-Abhaengigkeiten mitgedacht werden.
- Bestehende produktive Dashboard-Flows duerfen weiterhin bewusst auf Custom Cards aufbauen; eine Rueckmigration auf reine Standard-Lovelace-Karten ist kein Default-Ziel.

## Produktiv und entwicklungsrelevant

### Dashboard / Lovelace

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

### Integrationsnah / Backend

- `HACS`
- `AI Automation Suggester`
- `Watchman`
- `Node-RED Companion`
- `Homematic(IP) Local for OpenCCU`
- `Auto Backup`
- `Deutscher Wetterdienst`
- `Deutscher Wetterdienst (by hg1337)`
- `Roborock Custom Map`

### Theme

- `iOS Theme - Based on the system-wide light and dark mode UI`

## Modulrelevante Zuordnung

### Roborock

- `Xiaomi Vacuum Map Card`
- `Roborock Custom Map`

Hinweis:
- Vakuumsteuerung und Karten-/Map-Funktion sind verwandte, aber unterschiedliche Ebenen.

### Heating / HmIP

- `Homematic(IP) Local for OpenCCU`

### Shutters / Beschattung / Wetter

- `Homematic(IP) Local for OpenCCU`
- `Deutscher Wetterdienst`
- `Deutscher Wetterdienst (by hg1337)`
- `Horizon Card`
- `Weather Chart Card`

## Arbeitsregeln

### Bei Dashboard-Aenderungen

- pruefen, ob verwendete Custom Cards aus HACS stammen
- keine bestehende Card stillschweigend durch Standard-Lovelace ersetzen, wenn dadurch Verhalten oder UX verloren geht
- bei neuen Dashboard-Konzepten bevorzugt vorhandene, bereits installierte Karten nutzen
- globale Resource-Umbauten in `configuration.yaml` nur mit ausdruecklicher Absprache und aktivem Validierungsplan anfassen, weil sie dashboarduebergreifend produktive Custom Cards brechen koennen

### Bei Integrations- oder Modul-Aenderungen

- pruefen, ob das Modul auf eine HACS-Integration oder HACS-Map-/UI-Erweiterung angewiesen ist
- produktiv genutzte Custom Integrations nicht ohne ausdrueckliche Absprache aus dem Pfad nehmen

### Bei Dokumentation

- modulkritische HACS-Abhaengigkeiten in Modul-Doku und Modulregeln nennen
- die globale Voll-Liste bleibt in dieser Datei
