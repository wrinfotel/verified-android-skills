---
name: gradle-build-logic
description: >
  Gradle build discipline for Android projects: version catalogs over
  hardcoded coordinates, KSP over kapt, R8 minification for release,
  build-speed flags in gradle.properties, and convention plugins. Use when
  editing build.gradle.kts, libs.versions.toml, gradle.properties, or
  shared build logic. Core rules have machine checks in checks/.
version: 0.1.0
---

# Gradle Build Logic

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY build-script edit, run the Verification step (bottom of this
file).

## 1. Version catalogs — one source of dependency truth

MUST declare dependency coordinates and versions in
`gradle/libs.versions.toml` and reference them through type-safe `libs.*`
accessors. "Instead of hardcoding dependency names and versions in
individual build files and updating each entry whenever you need to
upgrade a dependency" — centralize them.

WRONG:
```kotlin
implementation("androidx.core:core-ktx:1.9.0")
```

RIGHT:
```kotlin
// gradle/libs.versions.toml: androidx-ktx = { ... version.ref = "ktx" }
implementation(libs.androidx.core.ktx)
```

## 2. KSP, not kapt

MUST use KSP for annotation processing: "kapt ... is significantly slower
than Kotlin KSP. If you ... use tools that process annotations (such as
Room) with KSP support, migrate to KSP." Use kapt only for processors
without KSP support (document the reason at the declaration).

WRONG:
```kotlin
kapt(libs.hilt.compiler)
```

RIGHT:
```kotlin
ksp(libs.hilt.compiler)
```

## 3. Release builds are minified

MUST enable R8 in the release build type of application modules:
"set isMinifyEnabled = true (for code optimization) and isShrinkResources
= true (for resource optimization) ... We recommend that you always enable
both settings." On AGP 9.3+ the `optimization { enable = true }` block
replaces both. Tests and libraries are exempt.

WRONG:
```kotlin
release {
    isMinifyEnabled = false
}
```

RIGHT:
```kotlin
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
}
```

## 4. Build-speed flags are on

MUST enable, in `gradle.properties`:
`org.gradle.caching=true` (the build cache is off by default),
`org.gradle.parallel=true` (parallel subproject execution), and
`org.gradle.configuration-cache=true` (verify plugin compatibility first).

WRONG:
```properties
# defaults: caching off, configuration cache off
```

RIGHT:
```properties
org.gradle.caching=true
org.gradle.parallel=true
org.gradle.configuration-cache=true
```

## 5. Convention plugins (review-verified)

For multi-module projects, share build configuration through convention
plugins in a `build-logic` included build instead of copy-pasting config
across modules. Reference catalog entries with `alias` and non-catalog
plugins (the convention plugins themselves) with `id`. Prefer type-safe
accessors (`implementation(...)`) and keep compiler options in the
convention plugin, not per module.

No deterministic check covers this section; verify against
references/gradle.md.

## Verification

Run after any build-script edit (from the project root):

```bash
bash <skill-dir>/checks/check_version_catalog.sh   <project-root>
bash <skill-dir>/checks/check_no_kapt.sh           <project-root>
bash <skill-dir>/checks/check_release_minify.sh    <project-root>
bash <skill-dir>/checks/check_gradle_properties.sh <project-root>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic text heuristics over build files; if release configuration
lives in a convention plugin, point the minify check at the build-logic
directory too.
