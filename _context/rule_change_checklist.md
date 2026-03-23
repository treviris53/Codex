# Rule Change Checklist

## Zweck

Diese Checkliste wird verwendet, wenn Regeldateien veraendert werden:

- `D:\Codex\AGENTS.md`
- `D:\Codex\README_AGENT.md`
- Dateien unter `D:\Codex\_context\`

Ziel:
- widerspruechliche Regeln vermeiden
- Verweise aktuell halten
- Doku, Regeln und Vorlagen konsistent halten

## Basisschritte bei jeder Regelaenderung

1. Welche Regeldatei wurde geaendert?
2. Welches Thema ist betroffen?
   - Pfade
   - Deployment
   - Architektur
   - Dashboard
   - Dokumentationspflicht
   - Modulregel
   - Umgebung / Shell / Runtime
3. Ist die geaenderte Datei fuer dieses Thema die autoritative Hauptdatei?
4. Muessen Verweise oder Kurzfassungen in anderen Dateien angepasst werden?

## Gegenpruefung nach Dateityp

### Wenn `AGENTS.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\_context\instruction_map.md`
- `D:\Codex\README_AGENT.md`
- thematisch passende `_context`-Datei:
  - `project_rules.md`
  - `architecture.md`
  - `deployment.md`
  - `modules\*.md`

Prueffrage:
- Entsteht eine neue Doppelregel oder ein Widerspruch?

### Wenn `_context/project_rules.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\AGENTS.md`
- `D:\Codex\_context\instruction_map.md`

Prueffrage:
- Ist die repo-weite Regel auch in der globalen Einstiegsebene noch korrekt dargestellt?

### Wenn `_context/architecture.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\AGENTS.md`
- `D:\Codex\_context\instruction_map.md`
- betroffene Modul-Doku unter `_ha_dokumentation/`, falls sich das Architekturmodell sichtbar geaendert hat

Prueffrage:
- Bleiben Schichtmodell, Dashboard-Regeln und Modul-Doku konsistent?

### Wenn `_context/deployment.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\AGENTS.md`
- `D:\Codex\README_AGENT.md`
- `D:\Codex\_context\instruction_map.md`

Prueffrage:
- Stimmen Runtime-Pfade, Deploy-Annahmen und Aktivierungslogik weiterhin ueberein?

### Wenn `_context/modules/<modul>.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\AGENTS.md`
- `D:\Codex\_context\instruction_map.md`
- zugehoerige Modul-Doku unter `D:\Codex\_ha_dokumentation\...`
- ggf. passende Startvorlagen unter `D:\Codex\_codex_vorlagen\`

Prueffrage:
- Spiegelt die Modul-Doku das neue Regel-/Betriebsmodell noch korrekt?

### Wenn `README_AGENT.md` geaendert wurde

Kurz gegenpruefen:

- `D:\Codex\AGENTS.md`
- `D:\Codex\_context\instruction_map.md`

Prueffrage:
- Bleibt die Schnellreferenz eine echte Kurzfassung und kein zweites Regelwerk?

## Themenbezogene Zusatzpruefung

### Bei Pfadregeln

Gegenpruefen:

- `AGENTS.md`
- `deployment.md`
- `instruction_map.md`

### Bei Dashboard-Regeln

Gegenpruefen:

- `AGENTS.md`
- `architecture.md`
- betroffene Modul-Doku

### Bei Dokumentationspflichten

Gegenpruefen:

- `AGENTS.md`
- `project_rules.md`
- betroffene Modulregel
- ggf. `_codex_vorlagen`

### Bei Deployment-/Runtime-Regeln

Gegenpruefen:

- `AGENTS.md`
- `deployment.md`
- `README_AGENT.md`

## Abschlussfrage

Vor Abschluss einer Regelaenderung kurz beantworten:

- Gibt es jetzt irgendwo noch eine alte, widerspruechliche Formulierung?

Wenn ja:
- im gleichen Task bereinigen oder zumindest explizit notieren.
