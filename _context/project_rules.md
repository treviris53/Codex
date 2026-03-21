# Project Rules

## Scope
Global rules for all changes in this repository.

## YAML
- Use LF line endings only.
- Ensure a newline at end of file.
- Do not leave trailing spaces.
- Keep YAML explicit and readable.

## Home Assistant
- Never rename existing `entity_id` values.
- Prefer additive changes over destructive rewrites.
- Do not introduce silent breaking changes.
- Keep helper ownership explicit.

## Scheduler
- Fixed slot models remain in place where they already exist.
- Do not introduce dynamic slot generation unless explicitly requested.

## Deployment
- Deploy only via project deployment scripts.
- Always review the diff before deployment.

## Change style
- Keep diffs minimal and stable.
- Preserve compatibility with existing dashboards, scripts, automations, and scenes.
