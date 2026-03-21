# Known Issues / Lessons Learned

## Job Map Bug
- flur_vm doppelt definiert → führte zu flur_saup_wisch
- Lösung: eindeutige Alias-Zuordnung

## input_text initial
- überschreibt restore_state
- → entfernt

## Dashboard Drift
- Program IDs müssen synchron mit program_map sein