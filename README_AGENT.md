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
- Guarded deploys support YAML, JSON, and JS
- After YAML or JSON object changes, emit a PowerShell-ready multi-line `$paths = @(...)` assignment; keep `$paths` tied to the latest YAML/JSON task files rather than later rule/docs edits; if the user sends exactly `$PATH`, output the current `$paths`

## Environment Summary

- Repository root: `D:\Codex`
- Runtime config path: `/config`
- Home Assistant installation: `HAOS`
- Confirmed runtime baseline as of `2026-03-22`:
  - Home Assistant OS `17.1`
  - Home Assistant Core `2026.3.2`
  - Supervisor available
- Packages in this repository live under `packages/`
- Versioned network architecture documents live under `_netzwerk/`
- Runtime package path is `/config/packages/`
- Deployment path is production-oriented via Samba and deployment script
- VS Code task integration exists for yamllint plus guarded preview, diff-only, WhatIf, and live deploy flows
- Default shell context is PowerShell on Windows 11
- WSL exists but is only a secondary / occasional context
- Treat changes as production-near and prefer small, low-risk updates

## Recommended VS Code Extensions

- Core for this repo: `YAML`, `YamLint Fix`, `PowerShell`, `Home Assistant Config Helper`, `Draw.io Integration`, `markdownlint`
- Helpful but optional: `Markdown All in One`, `Error Lens`, `Git History`
- Use `D:\Codex\_context\dev_tooling.md` for the fuller VS Code workspace setup, settings, and task guidance
