# Agent Instructions

Always read _context/*.md before making changes.

Key rules:
- Never modify HA runtime state
- Only deploy via deploy script
- program_map is authoritative
- job_map is alias layer only

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
- Default shell context is PowerShell on Windows 11
- WSL exists but is only a secondary / occasional context
- Treat changes as production-near and prefer small, low-risk updates
