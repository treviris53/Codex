# Agent Instructions

Always read _context/*.md before making changes.
For a quick navigation map of the rule system, read `_context/instruction_map.md`.
When changing instruction files, use `_context/rule_change_checklist.md`.

Key rules:
- Never modify HA runtime state
- Read productive logs / traces only in read-only diagnosis mode
- Only deploy via deploy script
- program_map is authoritative
- job_map is alias layer only
- For production-near deploys, prefer `deploy_ha_git_guard.ps1` or the VS Code tasks in `.vscode/tasks.json`
- Guarded deploys are YAML-only

## Environment Summary

- Repository root: `D:\Codex`
- Runtime config path: `/config`
- Home Assistant installation: `HAOS`
- Confirmed runtime baseline as of `2026-03-22`:
  - Home Assistant OS `17.1`
  - Home Assistant Core `2026.3.2`
  - Supervisor available
- Packages in this repository live under `packages/`
- Runtime package path is `/config/packages/`
- Deployment path is production-oriented via Samba and deployment script
- VS Code task integration exists for yamllint, preview, diff-only, and guarded live deploy flows
- Default shell context is PowerShell on Windows 11
- WSL exists but is only a secondary / occasional context
- Treat changes as production-near and prefer small, low-risk updates
