# Validation

## Proof Strategy

Use focused tests for changed behavior plus the project-wide Flutter validation
gate.

## Test Plan

| Layer | Cases |
| --- | --- |
| Unit | Network env reader, network redaction, auth retry using latest stored token. |
| Integration | App shell wires app-wide provider and route-scoped home Cubit. |
| E2E | Not required; no product flow exists. |
| Platform | Not required; no native platform behavior changed. |
| Performance | Not required; no performance-sensitive path changed. |
| Logs/Audit | Redaction test proves sensitive response fields are not emitted. |

## Fixtures

- Fake Dio adapter.
- In-memory token store.
- Fake local database service for widget tests.

## Commands

```text
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
! rg '\.sp\b' lib
! rg 'Theme\.of\(context\)\.textTheme' lib
test -z "$(git ls-files -- .env)"
scripts/bin/harness-cli query matrix
```

## Acceptance Evidence

- `dart format --set-exit-if-changed lib test`: passed after formatting, 50
  files checked.
- `flutter analyze`: passed, no issues found.
- `flutter test`: passed, 38 tests.
- `rg '\.sp\b' lib`: no matches.
- `rg 'Theme\.of\(context\)\.textTheme' lib`: no matches.
- `test -z "$(git ls-files -- .env)"`: passed.
- `scripts/bin/harness-cli query matrix`: passed after restoring Harness CLI
  v0.1.10 and importing brownfield docs; US-002 is implemented with unit and
  integration proof.
