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

### Do not rely on `#Preview` blocks in this sandboxed build path

- date: 2026-04-02
- area: macOS build verification
- mistake: leaving SwiftUI preview macros in source while verifying builds under the current sandboxed CLI environment
- impact: `swift-plugin-server` can fail and block otherwise valid builds
- prevention: remove preview macros or verify in Xcode GUI when preview support is needed
- status: active rule

### Do not overcomplicate the provider selector if the compiler starts crashing

- date: 2026-04-02
- area: SwiftUI implementation
- mistake: using a `Picker` with a method-reference setter in a path that triggered a Swift compiler crash during IR generation
- impact: a valid-looking view can fail the build with no useful source-level error
- prevention: simplify the affected view first, especially generic SwiftUI controls and bindings, before assuming the whole file is wrong
- status: active rule

### Do not forget to regenerate the XcodeGen project after adding source files

- date: 2026-04-02
- area: build workflow
- mistake: adding a new Swift file under `Sources/` and immediately rebuilding without regenerating `Paguro.xcodeproj`
- impact: the compiler reports missing types even though the new file exists on disk
- prevention: run `xcodegen generate` any time files are added or removed, then rebuild
- status: active rule
