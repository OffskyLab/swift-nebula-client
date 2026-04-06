# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow — MANDATORY

**All modifications and new features in `swift-nebula-client` must follow this process:**

1. **Use `superpowers` + TDD** — invoke the superpowers brainstorming/planning skills and follow TDD for every change.
2. **Every change must have test coverage** — no exception. If a feature or fix has no test case, it is not done.
3. **Minor changes** — if the change is very small (e.g. a one-line rename, doc fix), ask the user before skipping superpowers. Even then, TDD still applies: write the test first.

## Build & Test Commands

```bash
# Build
swift build

# Test
swift test

# Run a single test
swift test --filter NebulaClientTests.<TestClassName>/<testMethodName>
```

## Platform Policy: Linux First

This package is a client SDK for the Nebula framework. It runs on Linux as part of server-to-server communication.

- **Do not use Apple-only APIs** — no `import os`, no `OSAllocatedUnfairLock`, no macOS-only Foundation types.
- **Use cross-platform Swift stdlib and open-source packages only.**
- **macOS is development-only.** Minimum `.macOS(.v15)` is set solely for `Synchronization.Mutex` compatibility during local development.
