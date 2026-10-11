---
name: compose-multiplatform
description: >
  Compose Multiplatform discipline: shared UI in commonMain, multiplatform
  resources (Res, not R), Android-only Compose APIs kept in androidMain,
  and the single-Activity no-Fragments architecture. Use when writing or
  reviewing CMP UI code, wiring resources, or moving a screen from Android
  to shared code. Core rules have machine checks in checks/.
version: 0.1.0
---

# Compose Multiplatform

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY shared-UI edit, run the Verification step (bottom of this file).

## 1. Share the UI, split only the edges

CMP "shares the Compose compiler and runtime with Jetpack Compose and uses
the same APIs" — screens, themes, components, navigation, and ViewModels
belong in `commonMain`. Keep in platform source sets only entry points and
platform quirks (Android `MainActivity` + `setContent`, iOS `MainViewController`),
platform interop, and window handling.

## 2. Resources — Res, not R

MUST use Compose Multiplatform resources in common code: files under
`composeResources/`, accessed through the generated `Res` accessors with
`stringResource(Res.string.x)` / `painterResource(Res.drawable.x)` from
`org.jetbrains.compose.resources`. MUST NOT use the Android `R` class in
common code — "Compose Multiplatform uses the Res class via its resources
library; Android uses the R class".

WRONG:
```kotlin
// commonMain
import com.example.app.R

Text(text = stringResource(R.string.feed_title))
```

RIGHT:
```kotlin
// commonMain
import org.jetbrains.compose.resources.stringResource
import com.example.composeapp.generated.resources.Res

Text(text = stringResource(Res.string.feed_title))
```

## 3. Android-only Compose APIs stay in androidMain

MUST NOT import Android-only Compose APIs from common code — they are
"closely tied to the Android platform and are therefore not available from
common Compose Multiplatform code". The usual suspects the check flags:
`LocalContext` / `LocalView` / `LocalConfiguration`,
`androidx.compose.ui.res.*` (Android `stringResource`, `painterResource`),
and `AndroidView`. Reach them through `expect/actual`, or use the CMP
equivalents (`org.jetbrains.compose.resources.*`; on iOS `LocalUIViewController`
/ `UIKitView`).

WRONG:
```kotlin
// commonMain
import androidx.compose.ui.platform.LocalContext
val context = LocalContext.current
```

RIGHT:
```kotlin
// commonMain
expect fun appContext(): PlatformContext   // actualized per platform

// androidMain
actual fun appContext(): PlatformContext = LocalContext.current
```

## 4. No Fragments in a Compose-only app

MUST NOT use Fragments or AppCompat classes in common UI code: "For
Compose-only apps, do not use Fragments and instead use the recommended
Compose-only architecture with a single Activity". Fragments exist only
during a View→Compose migration (see the compose-migration skill).

WRONG:
```kotlin
// commonMain
class FeedFragment : Fragment()
```

RIGHT:
```kotlin
// commonMain
@Composable
fun FeedScreen(viewModel: FeedViewModel = koinViewModel())   // screen-level composable
```

## 5. Version compatibility (review-verified)

CMP "builds on code and releases published by Google"; on Android the
Google artifacts are used directly and elsewhere the JetBrains
multiplatform mirrors — substitution is automatic via Gradle Module
Metadata. When bumping Kotlin or CMP, consult the "Compatibility and
versions" map (references/multiplatform.md #2) before touching code; the
Compose compiler ships inside the Kotlin plugin since Kotlin 2.0.

## Verification

Run after any shared-UI edit (from the module's src root):

```bash
bash <skill-dir>/checks/check_no_r_class_in_common.sh                <src-root>
bash <skill-dir>/checks/check_no_android_only_compose_apis.sh        <src-root>
bash <skill-dir>/checks/check_no_fragments_in_common.sh              <src-root>
```

All three must pass (exit 0) before declaring the task done. Checks are
deterministic import/usage heuristics over commonMain/commonTest; the
Android-only API list in §3 is the documented heuristic subset — extend
it for stricter setups. §1 and §5 are review-verified against
references/multiplatform.md.
