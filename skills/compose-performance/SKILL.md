---
name: compose-performance
description: >
  Jetpack Compose performance discipline: stability, recomposition control,
  deferred state reads, and baseline profiles. Use when writing or reviewing
  Compose UI code, diagnosing recomposition storms, or preparing release
  builds. Every rule has a machine check in checks/.
version: 0.1.0
---

# Compose Performance

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY Compose UI edit, run the Verification step (bottom of this file).

## 1. Stability

MUST make UI-state data classes fully immutable (`val` only) and annotate
them `@Immutable` when they are passed as composable parameters.

WRONG:
```kotlin
data class UserUi(val name: String, var selected: Boolean)
```

RIGHT:
```kotlin
@Immutable
data class UserUi(val name: String, val selected: Boolean)
```

WHY: a single `var` property makes the class unstable. Every unstable
parameter defeats skipping for every composable that receives it, so one
mutable field can undo recomposition optimization across a whole screen.

MUST NOT pass `MutableList` / `MutableMap` / `MutableSet` as composable
parameters. Use `kotlinx.collections.immutable` types (`ImmutableList`,
`ImmutableMap`) or `@Immutable` wrappers.

WRONG:
```kotlin
@Composable
fun Feed(items: MutableList<String>) { ... }
```

RIGHT:
```kotlin
@Composable
fun Feed(items: ImmutableList<String>) { ... }
```

MUST NOT create mutable collections inside `remember` when the value only
feeds the UI. Prefer state-holder classes with immutable snapshots.

WRONG:
```kotlin
val history = remember { mutableListOf<Int>() }
```

RIGHT:
```kotlin
var history by remember { mutableStateOf(immutableListOf<Int>()) }
// or keep mutation inside a @Stable state-holder that exposes ImmutableList
```

## 2. Deferred state reads

MUST defer state reads to the lambda of the modifier or component that
needs them, so a changing value skips the parent recomposition.

WRONG:
```kotlin
val offset = scrollState.value
Row(modifier = Modifier.offset(x = offset.dp)) { Header() }
```

RIGHT:
```kotlin
Row(modifier = Modifier.offset { IntOffset(scrollState.value, 0) }) { Header() }
```

MUST use `derivedStateOf` when computing a value from state where only the
computed result matters (e.g. "show scroll-to-top button when scrolled").

WRONG:
```kotlin
val showButton = scrollState.value > 0   // recomposes on every pixel
```

RIGHT:
```kotlin
val showButton by remember { derivedStateOf { scrollState.value > 0 } }
```

## 3. Lazy lists

MUST provide a stable, unique `key` for every `items(...)` entry whose
content or identity changes independently of position.

WRONG:
```kotlin
LazyColumn { items(messages) { msg -> MessageRow(msg) } }
```

RIGHT:
```kotlin
LazyColumn { items(messages, key = { it.id }) { msg -> MessageRow(msg) } }
```

## 4. Baseline profiles

MUST include a baseline profile for release builds: either a
`src/main/baseline-prof.txt` or the `androidx.baselineprofile` Gradle
plugin wired to a macrobenchmark module.

Startup and first-frame jank are dominated by JIT; a baseline profile is
the single highest-leverage release setting.

## Verification

Run after every Compose-related edit (from the project root):

```bash
bash <skill-dir>/checks/check_no_var_in_ui_state.sh  <src-dir>
bash <skill-dir>/checks/check_immutable_collections.sh <src-dir>
bash <skill-dir>/checks/check_baseline_profile.sh    <project-root>
```

All three must pass (exit 0) before declaring the task done. Checks are
deterministic static heuristics — they catch the documented anti-patterns
above, not every perf bug. For deep verification use the Compose compiler
metrics report and a macrobenchmark, per references/stability.md.
