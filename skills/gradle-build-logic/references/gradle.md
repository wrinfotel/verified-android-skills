# Gradle build logic — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Migrate to version catalogs** — "instead of hardcoding dependency
   names and versions in individual build files and updating each entry
   whenever you need to upgrade a dependency, you can create a central
   version catalog of dependencies that various modules can reference in
   a type-safe way with Android Studio assistance"; `gradle/libs.versions.toml`
   structure ([versions]/[libraries]/[plugins]); kebab-case names; "use
   `alias` for plugins that come from the version catalog file and `id`
   for plugins that don't ... such as convention plugins".
   https://developer.android.com/build/migrate-to-catalogs

2. **Optimize your build speed** — "kapt ... is significantly slower than
   Kotlin KSP. If you ... use tools that process annotations (such as
   Room) with KSP support, migrate to KSP" (link: Migrate to KSP,
   /build/migrate-to-ksp); `org.gradle.configuration-cache=true` snippet
   with plugin-compatibility caveat; JVM args (ParallelGC, heap sizing);
   disabling Jetifier via `android.enableJetifier=false`.
   https://developer.android.com/build/optimize-your-build

3. **Enable app optimization with R8** (shrink-code) — "to enable app
   optimization, set isMinifyEnabled = true (for code optimization) and
   isShrinkResources = true (for resource optimization) in your release
   build's app-level build script. We recommend that you always enable
   both settings"; AGP 9.3+ `optimization { enable = true }` DSL with
   default keep rules; "you probably don't want to enable it for tests or
   libraries".
   https://developer.android.com/studio/build/shrink-code

4. **Improving the performance of Gradle builds** — build cache off by
   default, enable with `org.gradle.caching=true`; parallel execution via
   `org.gradle.parallel=true`; configuration cache via
   `org.gradle.configuration-cache=true`; verify each change with a
   build scan.
   https://docs.gradle.org/current/userguide/performance.html

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
