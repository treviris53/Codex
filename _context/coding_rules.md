# Coding Rules

## YAML
- LF only
- newline at EOF
- keine trailing spaces

## Home Assistant
- entity_ids niemals ändern
- nur additive Änderungen
- keine stillen Breaking Changes

## Scheduler
- 3 Slots pro Tag bleiben fix
- keine dynamischen Slots

## Deployment
- nur via Script
- immer vorher Diff prüfen