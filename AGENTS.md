# Home Assistant project rules

## Scope
This workspace contains Home Assistant configuration and supporting files.
Primary working directory: `D:\Codex`

## Local tools
- Do not assume `python`, `py`, or `yamllint` are on `PATH` in a new thread.
- Preferred Python interpreter: `D:\Codex\.venv\Scripts\python.exe`
- Preferred yamllint command: `D:\Codex\.venv\Scripts\yamllint.cmd`
- If needed, the packaged yamllint binary also exists at `D:\Codex\.venv\_python_home\Scripts\yamllint.exe`
- Run commands from `D:\Codex` so `.yamllint` at the workspace root is picked up automatically.

## Context files
- Treat Markdown files under `_context/` as project guidance for this workspace.
- If any `_context/` file conflicts with this `AGENTS.md`, follow `AGENTS.md`.
- Before making code or configuration changes, read `_context/project_rules.md`.
- Before changing Home Assistant architecture, packages, scripts, automations, or dashboards, read `_context/architecture.md`.
- Before using `_ha_runtime_snapshot/` for validation or debugging, read `_context/runtime_usage.md`.
- Before deployment work, read `_context/deployment.md`.
- When touching scheduler mappings, helper defaults, or dashboard/program consistency, check `_context/lessons_learned.md`.
- When touching Roborock packages, scripts, helpers, automations, or dashboards, read `_context/modules/roborock.md`.
- When touching Heating packages, scripts, helpers, automations, scenes, or dashboards, read `_context/modules/heating.md`.
- When touching Shutters / Beschattung packages, scripts, helpers, automations, or dashboards, read `_context/modules/shutters.md`.

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

## Documentation maintenance
- Treat documentation under `_ha_dokumentation/` as project guidance for established module behavior, operating flows, and dashboard structure.
- Before changing a documented module's architecture, behavior, helpers, scripts, automations, scenes, dashboards, mappings, diagnostics, or control flow, read the corresponding documentation in `_ha_dokumentation/`.
- If a change affects runtime behavior, control flow, mappings, helpers, diagnostics, dashboard entry points, troubleshooting, or operator-relevant structure, update the corresponding documentation in `_ha_dokumentation/` in the same task.
- If a documented flow changes and a related `.drawio` file exists, update that diagram in the same task.
- Pure formatting, comments, ownership notes, or other strictly non-functional cleanup do not require a documentation update unless clarity, ownership, or operating guidance changed.


## Additional Operational Constraints (Repository-Specific)

### 1. Root vs Packages (Strict Placement Rule)
New runtime logic MUST be added in `config/packages/<domain>/...`.

Root files:
- automations.yaml
- scripts.yaml
- scenes.yaml

are considered **legacy / compatibility layers**.

Rules:
- Do NOT move existing logic from root to packages unless explicitly requested
- Root automations may be:
  - documented
  - minimally normalized (e.g. descriptions, service-call style)
- Large-scale migrations require explicit approval

---

### 2. Entity Ownership Conflicts
If multiple modules write to the same entity/helper:

- DO NOT immediately refactor or merge logic
- FIRST:
  - identify the authoritative owner
  - mark all other writers as **legacy**
  - document the relationship clearly

- Functional consolidation must be proposed separately and include:
  - migration plan
  - rollback safety

---

### 3. Safe Non-Functional Changes (Allowed by Default)
The following changes are allowed WITHOUT explicit approval,
as long as runtime behavior does not change:

- adding `description` fields
- adding ownership / legacy comments
- converting device-based actions → entity/service calls (1:1 equivalent)
- formatting improvements and YAML cleanup
- adding or updating version headers (`# Version: x.y.z`)

Constraints:
- NO entity_id changes
- NO behavior changes
- NO structural refactors across domains
