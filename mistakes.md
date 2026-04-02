# Mistakes Log

Use this file to record concrete mistakes, bad assumptions, regressions, or planning errors so future agent runs can avoid repeating them.

## Entry Format

### Title

- date:
- area:
- mistake:
- impact:
- prevention:
- status:

## Seeded Lessons

### Do not assume all providers expose local real-time token usage

- date: 2026-04-02
- area: telemetry architecture
- mistake: treating Claude Code and local Codex CLI as if they offer the same local token telemetry surface
- impact: leads to impossible or misleading product designs
- prevention: verify each provider separately and design adapters around confirmed data sources only
- status: active rule

### Do not start with a full desktop app if the product is a menu bar widget

- date: 2026-04-02
- area: product scope
- mistake: thinking in terms of a large app window instead of the actual compact macOS menu bar use case
- impact: adds UI surface area and complexity that the product does not need
- prevention: optimize for the menu bar flow first and let larger windows remain optional
- status: active rule

### Do not make the menu bar icon too busy

- date: 2026-04-02
- area: visual design
- mistake: assuming constant animation in the top bar is desirable
- impact: degrades usability and makes the app feel noisy
- prevention: use stateful, low-frequency icon reactions instead of continuous motion
- status: active rule

### Do not tie gameplay logic directly to raw provider payloads

- date: 2026-04-02
- area: architecture
- mistake: letting UI or simulation depend on provider-specific response shapes
- impact: makes provider expansion and maintenance fragile
- prevention: normalize into internal usage events before applying gameplay rules
- status: active rule

### Do not parallelize dependent git setup steps

- date: 2026-04-02
- area: tooling workflow
- mistake: running `git init` and `git remote add` in parallel even though the second command depends on `.git` already existing
- impact: setup fails intermittently and creates avoidable noise during repository bootstrap
- prevention: run dependent setup commands sequentially; only parallelize independent reads or checks
- status: active rule
