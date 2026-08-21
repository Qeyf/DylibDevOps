# Diagnostic probe

`PremiumGateProbe.dylib` is intentionally non-mutating. It only observes `__sys_ui_shown` and exposes the predicted inverted gate value used by the static-analysis hypothesis.

It does **not** write preferences, hook methods, patch executable code, or unlock premium functionality.
