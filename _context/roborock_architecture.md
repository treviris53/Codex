# Roborock Architektur

## Core Prinzip
- program_map = einzige Quelle für echte HA Button Entities
- job_map = Alias Layer (Scheduler + UI)

## Regeln
- program_ids sind kanonisch
- job_map darf nur Aliases enthalten
- input_text helpers speichern CSV job aliases

## Busy System
- roborock_busy = Lock
- roborock_busy_since = nur bei acquisition gesetzt

## Migration Regeln
- keine initial: bei input_text
- Defaults nur via Bootstrap Script