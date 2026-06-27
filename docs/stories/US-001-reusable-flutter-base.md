# US-001 Reusable Flutter Base

## Status

implemented

## Lane

normal

## Product Contract

The repository provides a reusable Flutter starter structure with dependency
injection, app shell wiring, app-level Cubit configuration, shared widgets,
theme/routing modules, and a sample feature Cubit that future Flutter projects
can copy or extend.

## Relevant Product Docs

- `docs/ARCHITECTURE.md`

## Acceptance Criteria

- App starts through a bootstrapper that registers dependencies before UI.
- App-level state lives in `presentation_module/blocs` and is provided through
  `MultiBlocProvider`.
- Feature code follows `presentation_module/ui/<feature>/<feature>_cubit.dart`
  plus page/widget files.
- Shared UI primitives live under `presentation_module/shared_view`.
- Responsive sizing is initialized at the app root with `ScreenUtilInit`.
- Text sizing uses `flutter_screenutil` `.r` values instead of `.sp`.
- Product-specific code from the reference app is not copied into the base.

## Design Notes

- Commands: none.
- Queries: none.
- API: none.
- Tables: none.
- Domain rules: base app has no product domain yet.
- UI surfaces: sample home screen proves Cubit/provider/widget wiring.

## Validation

When updating durable proof status, use numeric booleans:
`scripts/bin/harness-cli story update --id US-001 --unit 1 --integration 1 --e2e 0 --platform 0`.

| Layer | Expected proof |
| --- | --- |
| Unit | `flutter test test/presentation_module/blocs/app_config_cubit_test.dart test/presentation_module/ui/home/home_cubit_test.dart` |
| Integration | `flutter test test/widget_test.dart` |
| E2E | Not required; no product flow yet. |
| Platform | Not required; no platform-specific code changed. |
| Release | `flutter analyze` and full `flutter test`. |

## Harness Delta

Updated `docs/ARCHITECTURE.md` from generic placeholder text to the selected
Flutter base pattern.

## Evidence

- Red: `flutter test` failed because `AppConfigCubit`, `HomeCubit`,
  `configureDependencies`, and `AppBootstrapper` were missing.
- Green: targeted tests passed for app config Cubit, home Cubit, and widget
  provider wiring.
- Full verification: `dart format lib test`, `flutter analyze`, `flutter test`,
  and `scripts/bin/harness-cli query matrix` all passed.
- Responsive update: widget tests verify `ScreenUtilInit` design size and `.r`
  text sizes for the sample home page.
- Style rule update: `BuildContext` theme/text extension added and `HomePage`
  now uses `final textTheme = context.textTheme` before `Text` widgets.
- Repository rule update: `docs/FLUTTER_STYLE.md` records that widgets must call
  Cubits, Cubits call repositories, and repositories return
  `Either<NetworkError, T>` via `Left(error)` / `Right(data)`.
- Repository example: added `ExampleApiClient`, `ExampleItem`, `NetworkError`,
  `ExampleRepository`, and `ExampleCubit` with tests for success and failure.
- Wrapper layout: added product-neutral `WrapperLayoutView` with configurable
  title, leading buttons, actions, background/gradient, bottom slots, and body
  padding.
