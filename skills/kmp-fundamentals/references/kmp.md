# KMP fundamentals — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Expect and actual declarations** — expect in the common source set
   ("shouldn't include any implementation"), actual in each platform
   source set "in the same package"; "every expected declaration in the
   common source set has a matching actual declaration in every
   platform-specific source set"; `actual typealias` connects an actual
   implementation to the expected declaration; "rely on standard language
   constructs wherever possible instead of using expected and actual
   declarations" — prefer a common interface (with a small expect/actual
   factory or DI) over expect classes; expected/actual classes are Beta
   and discouraged for simple cases.
   https://kotlinlang.org/docs/multiplatform/multiplatform-expect-actual.html

2. **Project structure** — `commonMain` "compiles to all declared
   targets"; "if the code is shared among all targets, it should be
   declared in commonMain"; platform source sets (androidMain, iosMain,
   jvmMain...) per target; intermediate source sets (e.g. `appleMain`)
   for platform-family sharing; "commonMain can't use code from jvmMain";
   the `java.io.File` example showing platform APIs are unavailable in
   common code; dependencies configured per source set; commonTest/
   platform test sets mirror Main source sets.
   https://kotlinlang.org/docs/multiplatform/multiplatform-discover-project.html

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
