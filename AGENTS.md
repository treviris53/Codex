# Home Assistant project rules

## Scope
This workspace contains Home Assistant configuration and supporting files.
Primary working directory: `D:\Codex`

## Context files
- Treat Markdown files under `_context/` as project guidance for this workspace.
- If any `_context/` file conflicts with this `AGENTS.md`, follow `AGENTS.md`.
- Before making code or configuration changes, read `_context/project_rules.md`.
- Before changing Home Assistant architecture, packages, scripts, automations, or dashboards, read `_context/architecture.md`.
- Before using `_ha_runtime_snapshot/` for validation or debugging, read `_context/runtime_usage.md`.
- Before deployment work, read `_context/deployment.md`.
- When touching scheduler mappings, helper defaults, or dashboard/program consistency, check `_context/lessons_learned.md`.
- When touching Roborock packages, scripts, helpers, automations, or dashboards, read `_context/modules/roborock.md`.

## Required behavior
- Never rename existing `entity_id` values.
- Prefer Home Assistant packages under `packages/`.
- Keep YAML explicit, readable, and maintainable.
- Prefer event-driven automations over polling.
- Use `alias` and `description` where supported.
- Do not hardcode secrets, tokens, passwords, or URLs with credentials.
- Use `!secret` for sensitive values.
- Keep diffs minimal and stable.
- Preserve compatibility with existing dashboards, automations, scripts, and scenes.
- When changing behavior, add a short migration note.

## Home Assistant package conventions
- Use paths like `packages/<domain>/<feature>.yaml`.
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
