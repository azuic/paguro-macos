# Implementation Plan

## Architecture Overview

Paguro should be split into four layers:

1. host shell
2. telemetry adapters
3. simulation and persistence
4. presentation layer

## Layer Details

### Host shell

Responsibilities:

- manage menu bar icon
- open and close compact pet window
- receive background updates
- schedule lightweight refreshes

Preferred stack:

- SwiftUI for app structure
- AppKit for status item control when needed
- XcodeGen for project generation, with the generated `.xcodeproj` committed for convenience

### Telemetry adapters

Responsibilities:

- ingest provider-specific usage data
- normalize all events into one internal shape
- store authoritative usage records
- emit safe deltas to simulation

Initial adapters:

- Claude adapter via local status line bridge
- OpenAI adapter via local proxy or wrapped API client

### Simulation and persistence

Responsibilities:

- pet state
- inventory
- item effects
- growth
- provider wallet accounting
- migrations and local storage

Suggested entities:

- `ProviderAccount`
- `UsageEvent`
- `Pet`
- `InventoryItem`
- `ShopItem`
- `Egg`
- `PetAppearance`

### Presentation layer

Responsibilities:

- compact pet habitat
- shop and inventory surfaces
- icon state updates
- small animations for state changes

## Event Flow

1. adapter receives provider update
2. update is normalized into `UsageEvent`
3. event is persisted
4. simulation derives energy delta
5. pet state is updated
6. UI and menu bar icon react to new state

## Initial Data Rules

- usage accounting must be idempotent
- deltas must be derived from stable identifiers where possible
- provisional usage must be reconciled against final authoritative usage
- gameplay logic must not depend on raw provider payloads

## Suggested Milestones

### Milestone 0

- repo docs
- architecture locked

### Milestone 1

- macOS menu bar shell
- compact pet window
- local state model with fake seed data

### Milestone 2

- Claude telemetry bridge
- live energy accumulation

### Milestone 3

- shop, bag, shell swaps, food effects

### Milestone 4

- OpenAI telemetry path
- second provider pet

### Milestone 5

- icon state polish
- onboarding
- persistence hardening

## Testing Priorities

- correct energy accumulation from usage deltas
- duplicate-event protection
- item purchase accounting
- persistence round-trips
- menu bar window open and close behavior
- provider disconnect and reconnect handling

## Risks

- telemetry source differences across providers
- overcoupling business logic to one provider
- excessive icon or animation churn in the menu bar
- fragile state accounting when sessions resume or reconnect
