# Release engineering — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Configure your build** — "The debug build type ... includes debugging
   tools and is signed with the debug key"; "The release build type
   applies ProGuard settings and is not signed by default"; release builds
   must be explicitly signed ("the build system does not sign the release
   version unless you explicitly specify signing settings"); DSL shapes:
   `getByName("release") { isMinifyEnabled = true ... }`.
   https://developer.android.com/studio/build

2. **Behavior changes: Android 12** — "If your app targets Android 12 or
   higher and contains activities, services, or broadcast receivers that
   use intent filters, you must explicitly declare the android:exported
   attribute for these app components"; warning: otherwise "your app can't
   be installed on a device that runs Android 12 or higher"; guidance: "If
   the app component includes the LAUNCHER category, set android:exported
   to true. In most other cases, set android:exported to false."
   https://developer.android.com/about/versions/12/behavior-changes-12

3. **Network security configuration** — "Starting with Android 9 (API
   level 28), cleartext support is disabled by default"; the default
   base-config is `cleartextTrafficPermitted="false"`; per-domain opt-in
   via `<domain-config cleartextTrafficPermitted="true">`; blanket
   opt-in "should be avoided whenever possible".
   https://developer.android.com/privacy-and-security/security-config

4. **Sign your app / publish** — Play App Signing keeps the app signing
   key with Google while the upload key rotates; release artifacts to
   Play ship as App Bundles; R8 mapping files are uploaded for crash
   deobfuscation (review-verified §5).
   https://developer.android.com/studio/publish/app-signing

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
