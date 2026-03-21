# Lessons Learned

## Scope
Known failure patterns and preventive rules from earlier changes.

## Alias mapping
Problem:
- Duplicate alias definitions caused wrong program resolution.

Rule:
- Alias mappings must be unique.
- Validate alias-to-program relationships when editing scheduler or job maps.

## Persistent helpers
Problem:
- `initial:` on persistent helpers overwrote restore-state behavior.

Rule:
- Do not use `initial:` on persistent `input_text` or similar user-editable helpers unless explicitly intended and documented.

## Dashboard consistency
Problem:
- Dashboard program IDs drifted from canonical mappings.

Rule:
- Keep dashboard IDs and labels aligned with canonical program mappings.
- Revalidate related dashboards whenever program maps change.
