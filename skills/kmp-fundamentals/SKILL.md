---
name: kmp-fundamentals
description: >
  Kotlin Multiplatform fundamentals: source-set discipline, expect/actual
  placement and balance, and multiplatform dependency choices. Use when
  writing or reviewing code in commonMain/platform source sets, adding
  expect declarations, or migrating shared logic to KMP. Core rules have
  machine checks in checks/.
version: 0.1.0
---

# KMP Fundamentals

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY expect/actual or source-set edit, run the Verification step
(bottom of this file). The checks give pre-compile feedback in seconds —
the compiler stays the ground truth.

## 1. Source-set discipline — no platform APIs in common

MUST keep common source sets (`commonMain`, `commonTest`) free of platform
SDK imports: `android.*`, `java.*` / `javax.*`, `com.android.*`,
`com.google.android.*`, `androidx.activity.*`, and Kotlin/Native
`platform.*`. Common code compiles to every target, where those SDKs do
not exist ("you can't use the java.io.File dependency from the common
code").

WRONG:
```kotlin
// commonMain/.../Greeting.kt
import java.io.File

fun greeting() {
    File("greeting.txt").writeText("Hello, Multiplatform!")
}
```

RIGHT:
```kotlin
// commonMain/.../Greeting.kt
import kotlinx.io.files.Path

fun greeting() {
    // use a multiplatform library (kotlinx-io, Ktor, kotlinx-datetime, ...)
}
```

`androidx.compose.*` / material3 and other Compose Multiplatform artifacts
are intentionally NOT flagged: they ship a common API. Shared platform-
family code (e.g. Apple APIs) belongs in intermediate source sets
(`appleMain`), not in `commonMain`.

## 2. expect/actual placement

MUST declare `expect` in the common source set and `actual` in each
platform-specific source set, in the same package — never the reverse.

WRONG:
```kotlin
// androidMain/.../Platform.android.kt
expect fun androidApiLevel(): Int        // expect belongs in commonMain

// commonMain/.../Platform.kt
actual fun logTag(): String = "shared"   // actual belongs in a platform set
```

RIGHT:
```kotlin
// commonMain/.../Platform.kt
expect fun androidApiLevel(): Int

// androidMain/.../Platform.android.kt
actual fun androidApiLevel(): Int = Build.VERSION.SDK_INT
```

## 3. expect/actual balance — and prefer interfaces

Every `expect` declaration MUST have an `actual` in every declared
platform source set; an `actual` without a matching `expect` does not
compile. The check below verifies the name balance across the whole
module before you build.

Prefer not needing expect/actual at all: "rely on standard language
constructs wherever possible" — a common interface with platform
implementations (wired by DI or a small expect/actual factory) beats
`expect class`. Expected/actual classes are Beta and recommended only for
inheriting platform classes.

WRONG:
```kotlin
// commonMain
expect class Logger() {
    fun log(message: String)
}
```

RIGHT:
```kotlin
// commonMain
interface Logger {
    fun log(message: String)
}
expect fun buildLogger(): Logger   // actualized per platform or via DI
```

## 4. Dependencies & libraries (review-verified)

- Add dependencies per source set: `commonMain.dependencies { }` for
  shared code, `androidMain.dependencies { }` for Android-only.
- In common code prefer multiplatform libraries — `kotlinx-coroutines`,
  `kotlinx-datetime`, `kotlinx-io`, `Ktor client`, `kotlinx.serialization`
  — over platform APIs.
- Platform-only libraries (Guava, Spring, Room desktop variants) go to
  the corresponding platform source set.
- Tests mirror sources: `commonTest` compiles to all targets; use
  `kotlin.test` there, platform frameworks only in platform test sets.

No deterministic check covers dependency wiring; verify against
references/kmp.md.

## Verification

Run after every KMP-related edit (from the module's src root, i.e. the
parent of commonMain/androidMain/...):

```bash
bash <skill-dir>/checks/check_no_platform_imports_in_common.sh <src-root>
bash <skill-dir>/checks/check_expect_actual_placement.sh       <src-root>
bash <skill-dir>/checks/check_expect_actual_balance.sh         <src-root>
```

All three must pass (exit 0) before declaring the task done. Checks are
deterministic file-level heuristics; per-target actual coverage and
signature matching are the compiler's job — the balance check catches the
forgotten platform file before you pay for a build.
