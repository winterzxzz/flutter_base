# Architecture

This repo is a reusable Flutter application base. It intentionally contains only
generic app infrastructure, a sample Cubit-backed home screen, and harness docs;
project-specific product behavior should be added as stories before feature
implementation.

## Selected Stack

- Flutter app targeting the standard Flutter platform folders in this repo.
- `flutter_bloc` Cubit/BLoC for presentation state.
- `get_it` for dependency registration.
- `equatable` for immutable state comparisons.
- `flutter_localizations` and `intl` for localization-ready app wiring.
- `flutter_screenutil` for responsive spacing, sizing, and text scaling. Text
  sizes use `.r` by project convention, not `.sp`.

## Discovery Before Shape

Before proposing implementation shape, identify:

- Product surfaces: browser, mobile, desktop, CLI, API, worker, or service.
- Runtime stack: language, framework, database, queues, providers, and hosting.
- Core domains: the product concepts that deserve stable names and contracts.
- Boundary inputs: user input, API requests, webhooks, jobs, files, credentials,
  provider payloads, and environment configuration.
- Validation ladder: the smallest checks that can prove the selected stack.

Record stack choices in `docs/decisions/` when they meaningfully constrain
future work.

## Default Layering

```text
data_module
  <- presentation_module blocs/cubits
      <- presentation_module pages/widgets
          <- main.dart bootstrap
```

Current Flutter folder shape:

```text
lib/
  core/di/                         dependency registration
  data_module/models/              reusable data/status models
  presentation_module/app.dart     MaterialApp shell
  presentation_module/blocs/       app-wide Cubits/BLoCs
  presentation_module/configs/     constants and routing
  presentation_module/extensions/  BuildContext theme/text helpers
  presentation_module/shared_view/ reusable widgets
  presentation_module/theme/       theme definitions
  presentation_module/ui/<feature> feature pages and feature Cubits
```

Widget code should import `presentation_module/extensions/extensions.dart`, then
declare `final textTheme = context.textTheme` before building `Text` widgets.
Text sizes use `flutter_screenutil` `.r`, not `.sp`.

Detailed Flutter code style rules live in `docs/FLUTTER_STYLE.md`. Keep
`AGENTS.md` short and use the style guide for examples.

This mirrors the source reference project's split between `data_module` and
`presentation_module`, but removes product-specific Firebase, ads, IAP, plant
APIs, generated files, and native service code so the base stays easy to reuse.

## Candidate Structure

```text
app/
  domain/
    entities/
    value-objects/
    repositories/
    services/

  application/
    commands/
    queries/
    handlers/

  infrastructure/
    database/
    logging/
    notifications/

  interface/
    controllers/
    dto/
    presenters/
    routes/
    middlewares/

surfaces/
  browser/
  mobile/
  desktop/
  cli/
```

This is a thinking template, not a scaffold. Create real folders only when a
story enters implementation and the selected stack needs them.

## Dependency Rule

Inner layers must not depend on outer layers.

| Layer | May depend on | Must not depend on |
| --- | --- | --- |
| domain | nothing project-external except tiny pure utilities | framework, database, UI, provider, process/env |
| application | domain | framework, UI, provider, database concrete clients |
| infrastructure | domain, application | interface controllers or UI |
| interface | all backend layers | UI state or platform shell assumptions |
| app surfaces | API contracts and app-facing clients | domain internals directly |

## Parse-First Boundary Rule

Unknown data must be parsed at boundaries before it enters inner code.

Boundaries include:

- HTTP request bodies, params, and query strings.
- Session payloads and identity claims.
- Environment variables.
- Database rows returned from external clients.
- Platform shell payloads.
- Deep links, tokens, and signed URLs.
- Provider webhooks, events, and async payloads.

Target flow:

```text
unknown input
  -> parser
  -> typed DTO or command
  -> application use case
  -> domain object/value object
```

Inner layers should work with meaningful product types such as `UserId`,
`AccountId`, `WorkspaceId`, `Role`, `DateRange`, or domain-specific IDs,
rather than repeatedly validating raw strings.

## Command/Query Boundary

If the product has both reads and writes, keep command/query separation clear at
the code level even when the storage layer is simple:

- Commands mutate state and own audit side effects.
- Queries read state and format for consumers.
- Shared domain rules live in domain/application, not controllers.

## Observability Contract

The future server should emit one canonical JSON log line per request with:

- timestamp
- level
- request_id
- user_id when known
- action
- duration_ms
- status_code
- message

Audit logs are product records. Application logs are operational records. Do not
use one as a substitute for the other.
