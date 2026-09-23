## Agent skills

### Issue tracker

Issues, specs, and implementation tickets are local Markdown files under `.scratch/`. Never publish or modify them in an external issue tracker. See `docs/agents/issue-tracker.md`.

### Domain docs

This repository uses the single-context domain documentation layout. See `docs/agents/domain.md`.

## KISS / Architecture

see `docs/KISS_GUIDELINES.md`

## Canonical Web V1 Reference

The completed MECHA//TODO Web V1 is available locally at:

`_reference/mecha-todo/`

Treat this checkout as read-only. Never modify files inside `_reference/`.

### Source of truth

For product and domain behavior, use:

`_reference/mecha-todo/CONTEXT.md`

For exact algorithms and constants, inspect:

- `_reference/mecha-todo/src/domain/`
- `_reference/mecha-todo/src/config/`
- the corresponding automated tests

For visual and interaction behavior, inspect the running Web V1,
its source, tests, and approved assets.

The Web V1 is a behavioral and visual reference, not an architecture
template. Do not mechanically translate SolidJS, IndexedDB, browser
state, CSS, or other web-specific implementation details into Android.

Implement the same product behavior using idiomatic native Android,
Kotlin, Jetpack Compose, Room, and Android platform conventions.

Android-specific implementation decisions documented in this repository
may differ from the Web implementation, but changes to product/domain
semantics must be explicit.
