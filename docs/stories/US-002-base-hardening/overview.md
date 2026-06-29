# Overview

## Current Behavior

The reusable Flutter base has the right main layers, but review found hardening
gaps: `.env` was tracked and bundled, network error logging could expose
response data, a feature Cubit was provided at the app root, the sample home
screen bypassed `WrapperLayoutView`, unknown routes fell back to home, README
was still the Flutter template, and the Codex style skill did not encode these
rules.

## Target Behavior

The base is safer and easier to reuse: local env files are ignored, client env
is public-only, network logging is debug-only and redacted, feature Cubits are
route-scoped, normal screens use `WrapperLayoutView`, unknown routes render a
not-found page, onboarding docs describe the project, and the style skill
captures the improved rules.

## Affected Users

- Developers starting a new Flutter product from this base.
- Agents implementing future features in this repo.

## Affected Product Docs

- `README.md`
- `docs/FLUTTER_STYLE.md`
- `AGENTS.md`
- `.codex/skills/flutter-base-style/SKILL.md`
- `docs/TEST_MATRIX.md`

## Non-Goals

- Add product-specific auth endpoints, premium flows, ads, Firebase, or IAP.
- Replace Flutter navigation with a third-party router.
- Store real secrets in the Flutter app.
