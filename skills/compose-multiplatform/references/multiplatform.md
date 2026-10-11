# Compose Multiplatform — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Compose Multiplatform and Jetpack Compose** — CMP "shares the Compose
   compiler and runtime with Jetpack Compose and uses the same APIs";
   component families (Material 3, Lifecycle, ViewModel, Navigation
   Compose...) are multiplatform; "the Android-only components page lists
   APIs that are closely tied to the Android platform and are therefore
   not available from common Compose Multiplatform code"; "Compose
   Multiplatform uses the Res class via its resources library; Android
   uses the R class"; "Compose Multiplatform builds on code and releases
   published by Google" with automatic artifact substitution via Gradle
   Module Metadata; version map on the "Compatibility and versions" page.
   https://kotlinlang.org/docs/multiplatform/compose-multiplatform-and-jetpack-compose.html

2. **Compose Multiplatform resources** — the resources library and Gradle
   plugin for accessing resources in common code; resources can live in
   any module or source set (Kotlin 2.0+); almost all resources read
   synchronously on the caller thread; raw/web files async.
   https://kotlinlang.org/docs/multiplatform/compose-multiplatform-resources.html

3. **KMP project structure** — commonMain compiles to all targets; code
   used by only one target belongs in that target's platform source set;
   commonMain cannot use platform code.
   https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html

4. **Compose in Views (migration interop)** — "For Compose-only apps, do
   not use Fragments and instead use the recommended Compose-only
   architecture with a single Activity and latest navigation libraries."
   https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
