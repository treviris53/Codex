# Deployment

## Scope
Deployment workflow and environment assumptions for this repository.

## Environment
- Local development root: `D:\Codex`
- Home Assistant config mounted via Samba: `W:\`
- No Git is used on the Home Assistant host.

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

## Supported options
- `-Paths`
- `-Backup`
- `-DiffOnly`
- `-DeleteRemoved`
- `-PostReload`
- `-HealthCheck`

## Secrets and environment
- Use `HA_URL` and `HA_TOKEN` from environment variables.
- Never hardcode credentials in scripts or YAML.
