# Development Tooling

## Scope
Recommended editor tooling for working in `D:\Codex`.

## Purpose
This file captures the expected VS Code setup so later threads do not have to rediscover:
- which extensions are actually useful here
- which workspace settings matter for HA YAML, Markdown, and PowerShell
- which VS Code tasks already exist for linting and guarded deploy flows

## Recommended VS Code extensions

### Core
- `YAML`
- `YamLint Fix`
- `PowerShell`
- `Home Assistant Config Helper`
- `Draw.io Integration`
- `markdownlint`

### Helpful but optional
- `Markdown All in One`
- `Error Lens`
- `Git History`

### Usually not essential for repo rules
- `GitHub Copilot Chat`
- `Home Assistant Theme Color Highlighter`

## Workspace settings

The repository-local VS Code settings live in:

- `D:\Codex\.vscode\settings.json`

Current intent of these settings:
- keep LF line endings and final newline behavior aligned with repository rules
- avoid surprise formatting on save
- default the integrated terminal to PowerShell
- support Home Assistant YAML tags such as `!secret` and `!include_dir_named`
- keep Markdown linting practical for documentation-heavy work

## Workspace tasks

The repository-local VS Code tasks live in:

- `D:\Codex\.vscode\tasks.json`

Current task categories:
- `yamllint` for current file, workspace, and selected presets
- guarded deploy preview / diff tasks for supported YAML / JSON deploy paths
- guarded `WhatIf` deploy tasks for supported YAML / JSON deploy paths
- guarded live deploy tasks

## Operational guidance

- Prefer the existing VS Code tasks over ad-hoc terminal retyping for routine lint and guarded deploy flows.
- Treat deploy tasks as production-near operations; use preview, diff, and `WhatIf` before live deploy when appropriate.
- Do not assume every installed extension is required for future contributors; the core list above is the recommended baseline.
