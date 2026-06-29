# Exec Plan

## Goal

Fix the review findings and encode the improved base rules for future agents.

## Scope

In scope:

- Stop tracking `.env` and add CI guard.
- Remove `.env` from bundled Flutter assets.
- Support public env config through `--dart-define` and optional product `.env`
  assets.
- Redact debug network error logs.
- Scope feature Cubits at route/page boundary.
- Use `WrapperLayoutView` for the sample home screen.
- Add product-neutral not-found routing.
- Replace Flutter template README.
- Update `docs/FLUTTER_STYLE.md`, `AGENTS.md`, and Codex skill copy.

Out of scope:

- Product-specific auth refresh implementation.
- Product-specific routes, API contracts, or domain features.
- Native platform secrets or release signing.

## Risk Classification

Risk flags:

- Audit/security: env and network logging rules.
- Public contracts: route behavior for unknown routes.
- Existing behavior: app shell and widget tests change.
- Weak proof: Harness CLI is missing until installed.

Hard gates:

- Audit/security.

## Work Phases

1. Discovery.
2. Code hardening.
3. Documentation and skill sync.
4. Validation.
5. Harness trace or documented blocker.

## Stop Conditions

Pause for human confirmation if:

- A product-specific secret or endpoint is needed.
- Validation commands need to be weakened.
- The Harness CLI cannot be restored without changing upstream Harness files.
