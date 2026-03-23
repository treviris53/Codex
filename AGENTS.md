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

## Repository vs Runtime Paths
- This Codex workspace uses the repository root `D:\Codex`.
- Within this repository, Home Assistant packages live under `packages/`.
- In the actual Home Assistant runtime, the corresponding location is `/config/packages/`.
- When editing files in this repository, use repository-relative paths such as `packages/<domain>/<feature>.yaml`.
- When describing Home Assistant runtime behavior in explanations or technical documentation, use runtime paths such as `/config/packages/...`.
- Do not create or reference `config/packages/...` as a repository path inside this workspace.

## Package Loading Assumption
- The current repository is configured to load packages via:
  `homeassistant:`
  `  packages: !include_dir_named packages`
- Treat this as the active package-loading model unless the repository configuration changes.
- Root files like `automations.yaml`, `scripts.yaml`, `scenes.yaml`, and `template: !include_dir_merge_list templates/` remain separate loading paths and must not be conflated with package files.

## Execution Context
- This repository is a development / staging workspace, not the live Home Assistant runtime.
- Changes made here are not automatically active in Home Assistant.
- Deployment or sync to the actual HA `/config` is a separate step.
- Treat this repository as the version-controlled source of truth for configuration changes unless a task explicitly targets deployment or runtime validation.

## Confirmed Environment
- Confirmed runtime environment as of `2026-03-22`:
  - Home Assistant OS `17.1`
  - Home Assistant Core `2026.3.2`
  - Supervisor is present and running
  - Real runtime config path is `/config`
- The Windows deployment mount `W:\` corresponds to the runtime path `/config`.
- This repository currently targets one productive Home Assistant instance, not a separate staging HA system.
- Treat changes as production-near work, but assume some controlled validation is possible through diff, dry-run, reload, restart, and health-check workflows.

## Path Usage Rules
- Prefer repository-relative paths for files inside this workspace, for example `packages/heating/heating_scripts.yaml`.
- Use runtime paths like `/config/packages/...` only when the runtime context is explicitly being described.
- Use absolute local filesystem paths only when the task specifically needs machine-local context, external directories, or user-facing file references.
- Make the context clear whenever both repository and runtime paths are relevant.

## Development Shell Context
- Default development shell context is PowerShell on Windows 11.
- Prefer PowerShell-native commands and path handling unless the task explicitly requires another shell.
- WSL exists but is used only rarely; do not assume WSL is the normal execution path.
- Git work may happen from Windows and occasionally with WSL involved, but PowerShell / Windows remains the primary context.

## Context files
- Treat Markdown files under `_context/` as project guidance for this workspace.
- If any `_context/` file conflicts with this `AGENTS.md`, follow `AGENTS.md`.
- Use `_context/instruction_map.md` as the quick navigation map for the rule system when orienting in a new thread.
- When changing rule files, use `_context/rule_change_checklist.md` to counter-check related instructions and avoid rule drift.
- Before making code or configuration changes, read `_context/project_rules.md`.
- Before changing Home Assistant architecture, packages, scripts, automations, or dashboards, read `_context/architecture.md`.
- Before changing dashboards or dashboard UX structure, read `_context/dashboard.md`.
- Before using `_ha_runtime_snapshot/`, `_ha_debug/`, or live runtime logs / traces for validation or debugging, read `_context/runtime_usage.md`.
- Before deployment work, read `_context/deployment.md`.
- When custom integrations, custom cards, HACS dependencies, or themes matter, read `_context/hacs_inventory.md`.
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
- Default change posture is conservative-to-balanced for production-near configuration: prefer small, reviewable, low-risk changes unless a broader change is explicitly requested.
- Do not make ad-hoc write changes directly in the live Home Assistant runtime; repository files are the authoritative write path unless a task explicitly requires deployment.
- Runtime access should default to read/validate/deploy workflows, not direct manual mutation on the HA host.
- Read-only access to productive logs, traces, and runtime diagnostics is allowed for debugging when it materially improves diagnosis.
- Pure debug / verification tasks must not perform runtime writes, direct file edits on `W:\`, service calls, helper toggles, reloads, or restarts unless the task explicitly moves from diagnosis to an approved activation step.
- HACS is installed and productively used; relevant custom integrations, custom cards, and themes must be considered when changing dashboards or dependent modules.

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
- Use `_context/deployment.md` for the detailed validation and activation matrix when reload/restart/deploy questions matter.

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
- Before changing a documented module's behavior or operator-facing flow, read the corresponding module documentation and keep it in sync in the same task.
- Pure formatting or strictly non-functional cleanup does not require documentation updates unless clarity, ownership, or operator guidance changed.
- Use `_context/project_rules.md`, module rules under `_context/modules/`, and `_context/instruction_map.md` for the fuller documentation-maintenance model.

## Dashboard rules
- Keep dashboards aligned with the authoritative package logic and safe script entrypoints.
- Prefer clear, compact dashboards with focused subviews over long scrolling pages.
- Preserve established navigation and operator-facing structure unless a dashboard change is explicitly requested.
- When dashboard entry points, diagnostics, or user workflows change, update the matching module documentation.
- Use `_context/architecture.md` for the fuller dashboard architecture and UX rules.


## Additional Operational Constraints (Repository-Specific)

### 1. Root vs Packages (Strict Placement Rule)
New runtime logic MUST be added in `packages/<domain>/...` within this repository.

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
