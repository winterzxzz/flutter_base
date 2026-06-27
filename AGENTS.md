# Agent Instructions

## Flutter Base Style

This project follows the style from
`/Users/winterzxzz/Documents/Work/Flutter/plant-id-flutter`, adapted for a
reusable base app. Keep product-specific plant, ads, Firebase, and IAP code out
of this base unless a story explicitly asks for it.

Detailed rules live in `docs/FLUTTER_STYLE.md`. Keep this file short.

Must-follow rules:

- Widgets call Cubits; widgets do not call repositories directly.
- Cubits call repositories; repositories call API clients/services.
- Repositories return `Either<NetworkError, T>` using `Left(error)` and
  `Right(data)`.
- New standard screens use `WrapperLayoutView` for shared Scaffold/AppBar
  chrome; details live in `docs/FLUTTER_STYLE.md`.
- In widgets use `final textTheme = context.textTheme`; do not repeat
  `Theme.of(context).textTheme` inside widget trees.
- Text sizes use `flutter_screenutil` `.r`, not `.sp`.
- Before completion run `dart format lib test`, `flutter analyze`,
  `flutter test`, `! rg '\.sp\b' lib`, and
  `! rg 'Theme\.of\(context\)\.textTheme' lib`.

<!-- HARNESS:BEGIN -->
## Harness

This repo uses Harness. Before work, read:

- `README.md`
- `docs/HARNESS.md`
- `docs/FEATURE_INTAKE.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTEXT_RULES.md`
- `docs/TOOL_REGISTRY.md`
- `scripts/bin/harness-cli query matrix` on macOS/Linux, or `.\scripts\bin\harness-cli.exe query matrix` on Windows

Use the Rust Harness CLI at `scripts/bin/harness-cli` on macOS/Linux or
`scripts/bin/harness-cli.exe` on Windows as the main operational tool. Before a
step that could use an external tool, run `scripts/bin/harness-cli query tools
--capability <name> --status present` to see what is equipped; an absent
capability is a clean skip.
<!-- HARNESS:END -->
