# Design

## Domain Model

No product domain model changes. This story hardens reusable app
infrastructure.

## Application Flow

App startup loads optional public env config, configures DI, and provides only
app-wide Cubits at the root. Feature Cubits are created at the route boundary.

## Interface Contract

- `AppRoutes.home` renders `HomePage` with `HomeCubit`.
- `AppRoutes.notFound` renders `NotFoundPage`.
- Unknown route names render `NotFoundPage` instead of silently falling back to
  home.

## Data Model

No database schema or migration changes.

## UI / Platform Impact

- `HomePage` uses `WrapperLayoutView`.
- `NotFoundPage` is product-neutral and uses shared layout conventions.
- `.env` is ignored and not declared as a Flutter asset; products can use
  `--dart-define=API_BASE_URL=...` for public client config.

## Observability

- `NetworkInterceptor` logs only when enabled.
- Debug log messages redact token, password, secret, authorization, and API-key
  shaped fields.
- `PrettyDioLogger` remains debug-only with request/response headers and bodies
  disabled by default.

## Alternatives Considered

1. Keep `.env` as a tracked placeholder. Rejected because the pattern trains
   future projects to commit local env files.
2. Keep unknown routes falling back to home. Rejected because broken deep links
   and route typos become invisible.
3. Move every Cubit to the app bootstrapper. Rejected because feature scope
   should not become global state.
