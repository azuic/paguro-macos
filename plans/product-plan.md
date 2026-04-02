# Product Plan

## Vision

Paguro turns AI token usage into a living desktop pet economy. Users accumulate energy from their real AI activity and spend it on cosmetic and progression items for a hermit crab companion.

## Core Experience

The app lives in the macOS menu bar.

Primary interaction loop:

1. user spends tokens in Claude or OpenAI-backed tools
2. Paguro records usage events
3. usage converts into energy
4. energy is spent on food, shells, and eggs
5. items affect appearance, growth, and future progression

## User-Facing Pillars

### 1. Passive reward loop

The app should feel rewarding without demanding constant attention.

### 2. Strong pet identity

The crab should feel like a creature, not a dashboard with a mascot.

### 3. Distinct provider companions

Users may have a Claude Paguro and an OpenAI Paguro with separate energy streams and progression.

### 4. Compact presence

The app should stay lightweight and menu-bar-native.

## V1 Scope

In scope:

- one compact menu bar popover or window
- one pet view per provider
- persistent pet state
- energy gain from real usage events
- small starter shop
- shell changes
- food effects on fullness and color or pattern traits
- egg purchase and hatch flow
- simple growth stages
- subtle menu bar icon reactions

Out of scope for V1:

- cloud sync
- social features
- marketplace or trading
- complex genetics simulation
- multi-platform desktop support
- broad plugin ecosystem

## Economy Assumptions

These are placeholders and should be validated in implementation:

- energy is derived from token usage deltas, not from button clicks
- item prices should feel reachable in normal daily usage
- expensive items should unlock visible changes, not only hidden stats
- egg purchases should be meaningful but not punitive

## Suggested Starter Economy

- food: low cost, immediate stat impact
- basic shells: low to mid cost, visible cosmetic change
- rare shells: higher cost, palette or pattern shift plus progression value
- egg: expensive, creates a new pet slot or hatchable state

## Visual Principles

- pixel-art inspired
- intentionally cute but not overly sugary
- menu bar icon should communicate mood at a glance
- popover should feel like a tiny habitat, not a settings panel

## Open Product Questions

- Should provider pets share one inventory or keep separate inventories?
- Should energy map to raw tokens, estimated dollars, or weighted points?
- What is the minimum supported macOS version?
- Should the first release support only one active pet at a time in the menu bar, even if multiple pets exist?
