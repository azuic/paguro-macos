# Paguro Agent Guide

## Project Summary

Paguro is a macOS menu bar virtual pet. The pet is a hermit crab that gains energy from AI token consumption and spends that energy on shells, food, and eggs.

The product is not a full desktop app first. The primary surface is:

- a menu bar icon in the macOS top bar
- a compact anchored popover or small window showing the pet terrarium
- subtle icon state changes based on the pet's status

## Product Direction

Current product direction:

- macOS-first
- small utility app, not a multi-window productivity app
- pet state persists locally
- separate provider telemetry feeds for Claude and OpenAI
- provider-specific pets are acceptable and likely clearer than one merged wallet

## Non-Negotiable Constraints

- Do not assume local Codex CLI exposes supported real-time token usage.
- Treat OpenAI usage as available only through a path we control, such as an API wrapper or local proxy.
- Treat Claude Code usage as available through a local bridge, most likely via status line integration.
- Keep menu bar animation subtle. Responsive is good; noisy is bad.
- Keep the pet engine separate from telemetry collection and separate from UI rendering.

## Preferred Technical Direction

Default direction unless the user changes it:

- native macOS shell using SwiftUI plus AppKit where needed
- `MenuBarExtra` or `NSStatusItem` for the menu bar experience
- local persistence for pets, inventory, progression, and usage events
- adapter layer per provider

React or Tauri can still be used later if the user explicitly prioritizes code reuse over native macOS fit.

## V1 Goal

Ship a small menu bar pet that can:

- render one compact pet view
- consume real provider usage events
- convert usage into energy
- spend energy on a small shop
- persist pet state between launches
- reflect pet mood and status in the menu bar icon

## Provider Rules

### Claude

- Use Claude Code session metadata made available to local integrations.
- Prefer cumulative totals plus delta calculation per session.
- Do not couple the UI directly to raw status line JSON.

### OpenAI

- Use a controlled API path for usage capture.
- Prefer authoritative final usage from API responses.
- If live animation is desired during streaming, estimation must be marked as provisional and reconciled against final usage.
- Do not present local Codex CLI usage as supported unless the product architecture changes and there is verified first-party support.

## Working Principles

- Build small and vertical first.
- Keep a clear separation between:
  - telemetry ingestion
  - pet economy and simulation
  - UI state and rendering
- Store authoritative usage events before deriving gameplay effects.
- Prefer explicit state machines over ad hoc booleans once implementation starts.
- Keep docs current when a decision becomes stable.

## Initial Build Order

1. Project scaffolding and documentation
2. Menu bar shell and compact pet window
3. Pet state model and persistence
4. Claude telemetry adapter
5. OpenAI telemetry adapter
6. Shop, inventory, shell progression, and egg lifecycle
7. Polished icon states and micro-animations

## Review Expectations

When reviewing code for this project, prioritize:

- incorrect provider usage assumptions
- coupling between UI and telemetry sources
- fragile persistence or migration logic
- noisy or battery-unfriendly update loops
- regressions in menu bar behavior or popover/window lifecycle
- missing tests around energy accounting and item effects

## Documents To Read First

- `agent.md`
- `plans/product-plan.md`
- `plans/implementation-plan.md`
- `mistakes.md`
- `CLAUDE.md`
