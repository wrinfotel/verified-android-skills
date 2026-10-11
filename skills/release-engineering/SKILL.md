---
name: release-engineering
description: >
  Android release readiness: the release build type must carry no debug
  tooling (isDebuggable) and never sign with the debug key, cleartext HTTP
  stays out of non-debug manifests, and intent-filtered components declare
  android:exported (Android 12+ install requirement). Use when touching
  build types, signing configs, or manifests. Core rules have machine
  checks in checks/.
version: 0.1.0
---

# Release Engineering

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY build-type, signing, or manifest edit, run the Verification step
(bottom of this file).

## 1. No debug tooling in the release build type

MUST NOT set `isDebuggable = true` in the `release` block. The debug build
type "includes debugging tools and is signed with the debug key"; the
release build type is the distribution build ("applies ProGuard settings
and is not signed by default"). A debuggable release ships the debugging
surface to users and weakens app security.

WRONG:
```kotlin
buildTypes {
    release {
        isDebuggable = true
    }
}
```

RIGHT: leave the default (`isDebuggable = false` in release); do debug
work in the `debug` build type.

## 2. Release never signs with the debug key

MUST NOT point the release `signingConfig` at the debug key
(`signingConfigs.debug` / `getByName("debug")`): the debug key is public
knowledge and "the debug build type ... is signed with the debug key".
The release type "is not signed by default" — sign it explicitly with a
release key (ideally via Play App Signing, see §5).

WRONG:
```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")
}
```

RIGHT:
```kotlin
release {
    signingConfig = signingConfigs.getByName("release")
}
```

## 3. Cleartext HTTP stays out of non-debug manifests

MUST NOT set `android:usesCleartextTraffic="true"` in the main (or
release) manifest: "Starting with Android 9 (API level 28), cleartext
support is disabled by default", and enabling it app-wide is "this
insecure configuration should be avoided whenever possible". If a domain
genuinely needs HTTP, use a scoped `domain-config` in the network security
config instead. The `src/debug` source set is exempt — pointing local dev
tools at plain HTTP is normal there.

WRONG (main AndroidManifest.xml):
```xml
<application android:usesCleartextTraffic="true">
```

RIGHT:
```xml
<!-- src/debug/AndroidManifest.xml -->
<application android:usesCleartextTraffic="true" />
```

## 4. Intent-filtered components declare android:exported

MUST declare `android:exported` on every activity, service, or broadcast
receiver that has an `<intent-filter>`: "If your app targets Android 12
or higher and contains activities, services, or broadcast receivers that
use intent filters, you must explicitly declare the android:exported
attribute" — otherwise "your app can't be installed on a device that runs
Android 12 or higher." Launcher activity: exported true; most others:
false.

WRONG:
```xml
<service android:name=".SyncService">
    <intent-filter>...</intent-filter>
</service>
```

RIGHT:
```xml
<service
    android:name=".SyncService"
    android:exported="false">
    <intent-filter>...</intent-filter>
</service>
```

## 5. What the checks cannot see (review-verified)

- Versioning discipline: `versionCode` monotonic across releases,
  meaningful `versionName`.
- Key management: Play App Signing (Google holds the app signing key;
  upload key rotates safely); keystores and passwords stay out of version
  control.
- Shipping pipeline: App Bundles (AAB) for Play, R8 mapping file upload
  for deobfuscating crashes, staged rollouts, release notes.

## Verification

Run after every build/manifest edit (from the project root):

```bash
bash <skill-dir>/checks/check_release_debuggable.sh  <project-or-module-dir>
bash <skill-dir>/checks/check_release_signing.sh     <project-or-module-dir>
bash <skill-dir>/checks/check_cleartext_traffic.sh   <project-or-module-dir>
bash <skill-dir>/checks/check_manifest_exported.sh   <project-or-module-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic heuristics — they catch the documented anti-patterns above,
not every release bug. §5 is verified by review against
references/release.md.
