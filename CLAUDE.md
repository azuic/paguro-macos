# CLAUDE.md

## Read This First

Before making changes, read:

1. `agent.md`
2. `plans/product-plan.md`
3. `plans/implementation-plan.md`
4. `mistakes.md`

## Project Intent

Paguro is a macOS menu bar hermit crab pet. It should feel like a small native utility, not a full dashboard app.

The preferred default stack is native macOS:

- SwiftUI for the app shell
- AppKit where menu bar control needs lower-level handling
- XcodeGen for project configuration and regeneration

Do not switch to Tauri or a broad cross-platform plan unless the user explicitly asks for that tradeoff.

## Telemetry Rules

- Claude usage should be treated as locally bridgeable.
- The current Claude bridge transport is a status-line-written snapshot file watched from app support.
- OpenAI usage should be treated as available only through a controlled API path such as a wrapper or proxy.
- Do not claim supported local Codex CLI usage telemetry unless it has been re-verified and documented.

## Exec Guidance

When implementing:

- keep telemetry adapters isolated from UI
- persist authoritative usage events before applying derived energy
- prefer small vertical slices over broad scaffolding
- optimize for a compact menu bar window first
- keep menu bar icon state changes subtle
- if project settings change, update `project.yml` and regenerate `Paguro.xcodeproj`

## Review Guidance

When asked to review, prioritize:

- incorrect assumptions about provider token telemetry
- broken energy accounting
- duplicate usage processing
- state persistence issues
- menu bar lifecycle bugs
- unnecessary UI bloat beyond the compact widget goal

## Documentation Rule

If a stable decision changes, update the relevant file in:

- `agent.md`
- `plans/`
- `mistakes.md`

Do not leave architecture changes undocumented.
