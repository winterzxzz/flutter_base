# Agent Instructions

## Flutter Base Style

This project follows the style from
`/Users/winterzxzz/Documents/Work/Flutter/plant-id-flutter`, adapted for a
reusable base app. Keep product-specific plant, ads, Firebase, and IAP code out
of this base unless a story explicitly asks for it.

Detailed rules live in `docs/FLUTTER_STYLE.md`. Project-scoped Codex skill
lives in `.codex/skills/flutter-base-style/SKILL.md`. Keep this file short.

### Source of truth (keep in sync)

`docs/FLUTTER_STYLE.md` is the canonical style guide. The same rules are
mirrored in two other places that different agents read:

- `AGENTS.md` (this file) — short must-follow list; read by Claude Code (via
  `CLAUDE.md`), OpenCode, and Antigravity.
- `.codex/skills/flutter-base-style/SKILL.md` — Codex skill copy.

When you change a style rule, edit `docs/FLUTTER_STYLE.md` first, then update
the must-follow bullets here and the matching section in `SKILL.md` so all three
stay consistent. Do not let them drift.

Must-follow rules:

- Widgets call Cubits; widgets do not call repositories directly.
- Cubits call repositories; repositories call API clients/services.
- Repositories return `Either<NetworkError, T>` using `Left(error)` and
  `Right(data)`.
- New standard screens use `WrapperLayoutView` for shared Scaffold/AppBar
  chrome; details live in `docs/FLUTTER_STYLE.md`.
- When a feature page grows too long, split it into sub-widgets under
  `presentation_module/ui/<feature>/widgets/`, exported from the feature barrel;
  prefer widget classes over private `_buildX()` helpers.
- Put a widget in `presentation_module/shared_view/` only when two or more
  features reuse it; otherwise keep it in the feature's `widgets/` folder.
- Store sensitive local data in encrypted Hive boxes using keys from
  `SecureStorageService`; plain Hive boxes are cache/preferences only.
- Build `Dio` via `NetworkUtils.createDio`; read base URLs/secrets through
  `NetworkUtils.requiredEnv` from `.env` (loaded by dotenv in `main`), never
  hard-coded. Return `NetworkError.fromDioError` and branch on `isUnauthorized`/
  `isTimeout`, not on message strings.
- Auth uses `AuthInterceptor` + `AuthTokenStore` (tokens in secure storage) with
  401 refresh-and-retry; products override `TokenRefresher`. Never read tokens
  or hard-code auth endpoints in Cubits/widgets.
- Keep only truly app-wide Cubits in the bootstrapper; provide feature/screen
  Cubits at route or page scope.
- Unknown routes render a product-neutral not-found page; never silently fall
  back to home.
- Flutter client env is public config only. Track `.env.example`, ignore `.env`,
  prefer `--dart-define`, and never put secrets in assets or client env files.
- Network logging is debug-only and redacted; do not log headers, bodies, tokens,
  passwords, secrets, or API keys in production.
- Keep CI green (`.github/workflows/ci.yml`): format, analyze, test, and the
  `.sp` / direct-`textTheme` guards run on every PR.
- In widgets use `final textTheme = context.textTheme`; do not repeat
  `Theme.of(context).textTheme` inside widget trees.
- Text sizes use `flutter_screenutil` `.r`, not `.sp`.
- Before completion run `dart format lib test`, `flutter analyze`,
  `flutter test`, `! rg '\.sp\b' lib`, and
  `! rg 'Theme\.of\(context\)\.textTheme' lib`.
- Before completion verify `.env` is not tracked with
  `test -z "$(git ls-files -- .env)"`.

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
