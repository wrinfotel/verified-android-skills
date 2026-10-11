---
name: compose-testing
description: >
  Jetpack Compose testing discipline: test-rule choice, synchronization
  without sleeps, ui-test dependencies, and semantics-based assertions.
  Use when writing or reviewing Compose UI tests. Core rules have machine
  checks in checks/.
version: 0.1.0
---

# Compose Testing

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY Compose test edit, run the Verification step (bottom of this
file).

## 1. Synchronization — never block, drive the clock

MUST NOT block the test thread (`Thread.sleep`, `SystemClock.sleep`,
`delay`) to "wait for the UI". Compose tests run on a virtual clock:
assertions and actions auto-synchronize on idle. For conditions the clock
cannot see (external data loading, non-Compose measure/draw) use
`waitUntil` and its helpers; for animations control `mainClock`.

WRONG:
```kotlin
@Test
fun feedLoads() {
    composeRule.setContent { FeedScreen() }
    Thread.sleep(2_000)                                  // real time, flaky
    composeRule.onNodeWithText("Done").assertIsDisplayed()
}
```

RIGHT:
```kotlin
@Test
fun feedLoads() {
    composeRule.setContent { FeedScreen() }
    composeRule.waitUntilExactlyOneExists(hasText("Done"), timeoutMillis = 5_000)
    composeRule.onNodeWithText("Done").assertIsDisplayed()
}
```

MUST drive `mainClock` instead of sleeping through animations:

WRONG:
```kotlin
Thread.sleep(1_000) // let the animation finish
```

RIGHT:
```kotlin
composeRule.mainClock.autoAdvance = false
composeRule.mainClock.advanceTimeBy(1_000)
```

MUST NOT gate tests on external blocking (`CountDownLatch`) where a
`waitUntil` API fits — external blocking does not advance the test clock.

## 2. Test rule choice

MUST use `createComposeRule()` for pure composable content and
`createAndroidComposeRule<Activity>()` when the test needs the Activity.
MUST NOT pair `ActivityScenarioRule` (or a manually launched activity) with
a `ComposeTestRule` — the activity is then launched twice, a classic
source of flakiness.

WRONG:
```kotlin
@get:Rule val composeRule = createComposeRule()
@get:Rule val activityRule = ActivityScenarioRule(MainActivity::class.java)
```

RIGHT:
```kotlin
@get:Rule val composeRule = createAndroidComposeRule<MainActivity>()
```

## 3. Test dependencies

MUST declare, in the module holding the UI tests:

```kotlin
androidTestImplementation("androidx.compose.ui:ui-test-junit4:...")
debugImplementation("androidx.compose.ui:ui-test-manifest:...")
```

`ui-test-junit4` provides the rules; `ui-test-manifest` registers the
empty activity `createComposeRule()` needs (not required for
`createAndroidComposeRule<YourActivity>()`).

## 4. Semantics-based assertions

MUST find nodes through semantics: `onNodeWithText` / `onNodeWithTag` /
`onNodeWithContentDescription`, and assert visibility with
`assertIsDisplayed()` — existence is not visibility. Add `testTag` or
`semantics { contentDescription = ... }` only when no natural matcher
exists; keep tags in a shared constants object.

WRONG:
```kotlin
composeRule.onNodeWithText("Submit").assertExists()   // exists ≠ visible
composeRule.onNodeWithTag("btn_1")                    // ad-hoc tag literal
```

RIGHT:
```kotlin
composeRule.onNodeWithText("Submit").assertIsDisplayed()
composeRule.onNodeWithTag(TestTags.Submit)            // shared constants
```

This section is review-verified (no deterministic check): the checks
cannot see which matcher fits your UI.

## Verification

Run after every Compose test edit (from the project root):

```bash
bash <skill-dir>/checks/check_no_sleep_in_compose_tests.sh <src-dir>
bash <skill-dir>/checks/check_no_activity_scenario_rule.sh <src-dir>
bash <skill-dir>/checks/check_ui_test_dependencies.sh      <project-or-src-dir>
```

All three must pass (exit 0) before declaring the task done. Checks are
deterministic import/call-site heuristics — they catch the documented
anti-patterns above, not every testing bug. Assertion quality (§4) is
verified by review against references/testing.md.
