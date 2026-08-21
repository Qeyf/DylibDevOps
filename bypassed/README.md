# PremiumBypass

Authorized regression PoC for the supplied `PinterestPatch.dylib` build.

The module exercises the recovered `NSUserDefaults` gate hypothesis by setting:

`__sys_ui_shown = YES`

at dylib initialization time.

GitHub Actions run #5 successfully built an iOS arm64 Mach-O dylib with Xcode 26.6 / iOS SDK 26.5. The successful build SHA-256 is recorded in `SHA256SUMS`.

The workflow publishes the compiled `PremiumBypass.dylib` inside the `dylib-verification-*` Actions artifact.
