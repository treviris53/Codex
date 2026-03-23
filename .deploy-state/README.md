# Deploy State

This folder stores local deployment metadata for guarded Home Assistant deploys.

Rules:

- `*.toml` files in this folder are machine-local state and are intentionally ignored by Git.
- The recorded state is observational metadata only. It does not replace Git history or Home Assistant backups.
- The active content policy for guarded deploys is YAML-only. Non-YAML files must never be deployed through this flow.
- Runtime writes still happen only through `D:\Codex\deploy_ha_samba_healthcheck.ps1`.

Current intended usage:

- `live.toml` records the last successful guarded deploy for the productive Home Assistant instance.
