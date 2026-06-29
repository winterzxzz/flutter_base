# Flutter Base

Reusable Flutter starter with Cubit state, `get_it` DI, typed network errors,
Retrofit API clients, secure local storage, wrapper layouts, routing, CI, and
Harness operating docs.

## Setup

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

`API_BASE_URL` is client-visible config. Do not put secrets in Flutter assets,
`.env`, `--dart-define`, or checked-in files. Runtime tokens belong in secure
storage, and server/provider secrets belong outside the app.

`.env.example` documents public keys. `.env` is ignored and not bundled by this
base. Products may add their own optional `.env` asset later when that tradeoff
is intentional.

## Architecture

```text
lib/
  core/di/                         get_it registration
  data_module/api/                 Retrofit API clients and interceptors
  data_module/error/               typed failures
  data_module/models/              json_annotation DTOs/models
  data_module/networks/            Dio, env, auth token refresh
  data_module/repositories/        contracts and implementations
  data_module/services/            local/provider service wrappers
  presentation_module/app.dart     MaterialApp shell
  presentation_module/blocs/       truly app-wide Cubits
  presentation_module/configs/     constants and routing
  presentation_module/extensions/  BuildContext helpers
  presentation_module/shared_view/ reusable widgets and layouts
  presentation_module/theme/       theme definitions
  presentation_module/ui/<feature> feature page, Cubit, state, widgets
```

Flow:

```text
Widget -> Cubit -> Repository -> ApiClient/Service
```

Screen Cubits are provided at route/page scope. App bootstrap only provides
state that is truly global, such as theme or locale.

## Feature Pattern

- Normal screens use `WrapperLayoutView`.
- Feature widgets stay in `presentation_module/ui/<feature>/widgets/` until two
  or more features reuse them.
- Shared widgets live in `presentation_module/shared_view/` and stay
  presentational.
- Text uses `final textTheme = context.textTheme`; text sizes use `.r`, not
  `.sp`.
- Repositories return `Either<NetworkError, T>`.

## Validation

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
! rg '\.sp\b' lib
! rg 'Theme\.of\(context\)\.textTheme' lib
test -z "$(git ls-files -- .env)"
```

CI runs the same guard set on push to `master` and pull requests.

## Code Generation

Run this after changing Retrofit clients or `json_annotation` models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generated `*.g.dart` files are build outputs; do not hand-edit them.

## Harness

Harness docs live under `docs/`. Agents should follow `AGENTS.md` before
changing code. The durable Harness CLI is expected at `scripts/bin/harness-cli`
when installed.
