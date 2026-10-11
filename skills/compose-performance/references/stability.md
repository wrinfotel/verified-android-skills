# Stability & recomposition — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Stability in Compose** — what makes a type stable/unstable, why `var`
   and non-immutable collections break skipping, `@Immutable` / `@Stable`.
   https://developer.android.com/develop/ui/compose/performance/stability

2. **Compose performance best practices** — deferred state reads
   (`Modifier.offset {}` lambda), `derivedStateOf`, lazy list keys,
   `movableContentOf`.
   https://developer.android.com/develop/ui/compose/performance/bestpractices

3. **Strong skipping mode** (default in current Compose compilers) — what it
   does and does not excuse: it memoizes unstable parameters, but does not
   make lambdas capturing unstable values skippable in all cases; the
   immutability rules above still apply.
   https://developer.android.com/develop/ui/compose/performance/stability/strong-skipping

4. **Baseline profiles** — `androidx.baselineprofile` Gradle plugin, the
   `BaselineProfileRule` macrobenchmark, expected startup wins.
   https://developer.android.com/topic/performance/baselineprofiles

5. **Compose compiler metrics** — how to read stability reports for classes
   the checks below cannot see (multi-module types, external libraries).
   https://developer.android.com/jetpack/compose/performance/compose-metrics

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
