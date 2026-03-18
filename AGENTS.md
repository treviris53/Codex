# Home Assistant project rules

## Scope
This workspace contains Home Assistant configuration and supporting files.
Primary working directory: `D:\codex`

## Required behavior
- Never rename existing `entity_id` values.
- Prefer Home Assistant packages under `config/packages/`.
- Keep YAML explicit, readable, and maintainable.
- Prefer event-driven automations over polling.
- Use `alias` and `description` where supported.
- Do not hardcode secrets, tokens, passwords, or URLs with credentials.
- Use `!secret` for sensitive values.
- Keep diffs minimal and stable.
- Preserve compatibility with existing dashboards, automations, scripts, and scenes.
- When changing behavior, add a short migration note.

## Home Assistant package conventions
- Use paths like `config/packages/<domain>/<feature>.yaml`.
- Keep packages cohesive and production-ready.
- Add a semantic version header comment to new YAML files:
  `# Version: XX.YY.ZZ`
- Prefer idempotent automations and scripts.
- Use helper entities for overrides, cooldowns, and diagnostics where useful.
- Avoid high-frequency triggers unless explicitly required.

## Validation expectations
Before proposing a final change:
- check YAML syntax
- check for accidental `entity_id` renames
- call out placeholders clearly
- summarize changed files

## Documentation expectations
For substantial Home Assistant changes, include:
- purpose
- dependencies
- inputs / parameters
- outputs / side effects
- troubleshooting notes
- validation checklist