# Home Assistant Setup – Development Context

## 1. Environment

- Local development root: `D:\Codex`
- Home Assistant config mounted via Samba: `W:\`
- No Git on Home Assistant (intentional design decision)
- Deployment is handled externally via PowerShell script

---

## 2. Deployment Strategy

### Tool
`deploy_ha_samba_healthcheck.ps1`

### Key characteristics
- Explicit deployment via `-Paths` only (no implicit defaults)
- Optional backup before overwrite (`-Backup`)
- Diff mode (`-DiffOnly`)
- Optional cleanup (`-DeleteRemoved`)
- Post-deploy HA reload via API (`-PostReload`)
- Health validation via HA API (`-HealthCheck`)
- Uses environment variables:
  - `HA_URL`
  - `HA_TOKEN`

### Deployment flow
1. Diff check (`-DiffOnly`)
2. Dry run (`-WhatIf`)
3. Deploy with backup
4. HA reload (automation/script)
5. Health check (API + selected entities)

---

## 3. Architecture Principles

### General
- Strict separation of concerns
- No hidden dependencies across packages
- No direct entity manipulation from dashboards
- All runtime logic centralized in scripts

---

## 4. Package Structure (Standard Pattern)

Each functional module follows a layered architecture:

### 1. Core Layer
Responsibilities:
- Execution logic
- State transitions
- Locking (e.g. busy handling)
- Error handling
- Program orchestration

### 2. Scheduler Layer
Responsibilities:
- Time-based triggering
- Weekday validation
- Slot handling
- Dispatching only (no execution logic)

### 3. Helper Layer
Responsibilities:
- User-editable configuration
- Input booleans, datetimes, texts
- No runtime logic

### 4. Dashboard Layer
Responsibilities:
- Visualization only
- Calls scripts (never direct service calls like button.press)

---

## 5. State Management Rules

### Busy Lock Pattern
- `input_boolean.<module>_busy`
- Owned exclusively by core execution
- Prevents concurrent runs

### Timestamp
- `input_datetime.<module>_busy_since`
- Written only when lock is acquired
- Never overwritten on restart

### Rule
Only the core layer is allowed to:
- set busy = on/off
- write timestamps

---

## 6. Helper Philosophy

- No `initial:` for persistent user-editable helpers
- Use restore-state behavior instead
- Defaults are applied only via:
  - one-time bootstrap scripts
  - or manual migration tools

---

## 7. Scheduler Design

- Fixed slot model (e.g. 3 slots per day)
- Time is defined via `input_datetime`
- Jobs defined via `input_text` (CSV)
- Scheduler:
  - validates weekday
  - checks enable flags
  - resolves job → program mapping
  - never executes directly

---

## 8. Execution Model

Execution chain:

Scheduler / Dashboard
↓
script.run_named_program OR script.execute_job_chain
↓
script.execute_program_job
↓
Core logic (mapping, validation, lifecycle)


### Rules
- No direct hardware calls outside core
- All failure paths must:
  - clear busy lock
  - reset current state
  - log error

---

## 9. Dashboard Rules

- No direct `button.press`
- Only call safe scripts
- Display diagnostics:
  - ready / blocked state
  - last job / program
  - busy status

---

## 10. Validation Strategy

Before activating any module:

### Must pass:
- Busy lock lifecycle correct
- All failure paths clean up state
- Restart behavior stable
- Scheduler respects weekday + enable flags
- No duplicate helper ownership
- No state corruption after restart

---

## 11. Current Implementations

### Roborock (reference implementation)
- Fully refactored
- Implements:
  - core execution layer
  - scheduler layer
  - dashboard abstraction
  - strict busy-lock handling
- Serves as template for other modules

---

## 12. Design Goals for Future Modules (e.g. Shutters)

- Follow same 4-layer architecture
- No direct entity coupling
- Explicit ownership of all helpers
- Deterministic execution behavior
- Full restart safety
- No hidden cross-package dependencies

---

## 13. Non-Goals

- No automation logic in dashboards
- No implicit defaults in helpers
- No runtime logic in scheduler
- No Git dependency on HA host

---

## 14. Expected Assistant Behavior

When working on this project:

- Do NOT redesign architecture from scratch
- Follow the existing layering strictly
- Reuse patterns from Roborock module
- Avoid introducing hidden dependencies
- Prefer explicit, deterministic logic
- Validate restart and failure behavior
