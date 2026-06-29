# Test Matrix

This file maps product behavior to proof.

No product behavior has been defined or implemented yet. Do not mark a row
implemented until tests or validation evidence exist.

## Status Values

| Status | Meaning |
| --- | --- |
| planned | Accepted as intended behavior, not implemented |
| in_progress | Actively being built |
| implemented | Implemented and proof exists |
| changed | Contract changed after earlier implementation |
| retired | No longer part of the product contract |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-001 | Reusable Flutter starter structure and Cubit app shell | yes | yes | no | no | implemented | `flutter test test/presentation_module/blocs/app_config_cubit_test.dart test/presentation_module/ui/home/home_cubit_test.dart test/widget_test.dart` |
| US-002 | Base hardening for env, logging, route scope, wrapper usage, not-found routing, docs, and skill rules | yes | yes | no | no | implemented | `dart format --set-exit-if-changed lib test`; `flutter analyze`; `flutter test`; `! rg '\.sp\b' lib`; `! rg 'Theme\.of\(context\)\.textTheme' lib`; `test -z "$(git ls-files -- .env)"` |

## Evidence Rules

- Unit proof covers pure domain and application rules.
- Integration proof covers backend enforcement, data integrity, provider
  behavior, jobs, or service contracts.
- E2E proof covers user-visible browser flows.
- Platform proof covers only shell, deployment, mobile, desktop, or runtime
  behavior that cannot be proven in lower layers.
- A story can be implemented without every proof column if the story packet
  explains why.
