# Deployment

## Scope
Deployment workflow and environment assumptions for this repository.

## Environment
- Local development root: `D:\Codex`
- Home Assistant config mounted via Samba: `W:\`
- Home Assistant runtime config path: `/config`
- `W:\` is the Windows-mounted view of the live Home Assistant `/config`.
- Home Assistant installation type: `HAOS`
- Confirmed runtime as of `2026-03-22`:
  - Home Assistant OS `17.1`
  - Home Assistant Core `2026.3.2`
- Add-ons are available on the HA host.
- No Git is used on the Home Assistant host.
- This repository deploys to one productive Home Assistant instance; there is no separate staging HA environment in the confirmed baseline.

## Runtime write policy
- Treat repository files under `D:\Codex` as the authoritative write source.
- Do not make ad-hoc configuration edits directly in the live HA runtime when the same change belongs in the repository.
- Use the repository -> deploy-script -> HA workflow as the default path for live changes.
- Direct runtime inspection is acceptable for validation and debugging; direct runtime mutation should be avoided unless a task explicitly requires it.

## Deployment tool
Primary deployment script:
- `deploy_ha_samba_healthcheck.ps1`

## Required workflow
1. Review the intended file paths.
2. Run a diff check with `-DiffOnly`.
3. Run a dry run with `-WhatIf` when appropriate.
4. Deploy with backup when changing live configuration.
5. Run post-reload when required.
6. Run health validation after deployment.
7. Escalate to a full Home Assistant restart only when reload services are insufficient or the change explicitly requires restart semantics.

## Supported options
- `-Paths`
- `-Backup`
- `-DiffOnly`
- `-DeleteRemoved`
- `-PostReload`
- `-HealthCheck`

## Activation model
- After deployment, changes may become active through reload services, a Home Assistant restart, or a combination of both depending on the affected subsystem.
- Prefer reload-capable workflows first when they are functionally sufficient.
- Be explicit when a change likely needs restart instead of reload-only behavior.

## Validation and activation matrix
- YAML-only content change:
  - Required baseline: YAML syntax check and changed-file review
- Automation / script / template package change:
  - Preferred activation: reload-capable workflow where sufficient
  - Required validation: YAML check, targeted reload or restart decision, health validation
- Scene / helper / package structure change:
  - Preferred activation: evaluate whether reload is sufficient; escalate to restart when needed
  - Required validation: YAML check, activation-path decision, post-deploy validation
- Dashboard-only YAML change:
  - Required validation: changed-file review and dashboard consistency review
  - Reload / restart only if the affected subsystem requires it
- Cross-module or architecture-affecting change:
  - Required validation: YAML check, diff review, explicit reload-vs-restart decision, health validation, and documentation consistency review

## Secrets and environment
- Use `HA_URL` and `HA_TOKEN` from environment variables.
- Never hardcode credentials in scripts or YAML.
