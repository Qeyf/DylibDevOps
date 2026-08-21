# DylibDevOps

Regression workspace for validating static-analysis hypotheses against `PinterestPatch.dylib`.

## Layout

- `original/` — original supplied dylib and integrity metadata.
- `verification/` — non-bypass diagnostic dylib source. It reads the observed preference state and exposes/logs the predicted gate value without mutating application state, hooking methods, patching code, or unlocking paid functionality.
- `analysis/` — CI-side integrity and hypothesis checks.
- `.github/workflows/verify.yml` — builds the diagnostic dylib and runs verification checks on GitHub Actions.

## Hypothesis under test

The static-analysis hypothesis is that the protected flow observes the `NSUserDefaults` key `__sys_ui_shown` and derives an inverted gate predicate from that state.

The original module supplied for this test has SHA-256:

`bd86770c05e8a290d9b729f8922c3f3f8fde737e8463c79d4bf4dbc4d86ce017`

CI records the original binary identity and builds a diagnostic probe so this hypothesis can be tested without shipping a premium-access bypass.
