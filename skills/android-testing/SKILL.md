---
name: android-testing
description: >
  Android testing discipline: test taxonomy and source sets, Gradle scopes
  for test-only dependencies, Robolectric placement, the deprecated
  ActivityTestRule, and Espresso synchronization without sleeps.
  Use when writing or reviewing local unit tests, instrumented tests,
  Robolectric tests, or Espresso tests. Core rules have machine checks
  in checks/.
version: 0.1.0
---

# Android Testing

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY Android test edit, run the Verification step (bottom of this
file). Compose UI tests are covered by the `compose-testing` skill.

## 1. Taxonomy — where a test lives

MUST put JVM tests in `module-name/src/test/` and device tests in
`module-name/src/androidTest/`. Robolectric runs a simulated Android
environment inside a JVM — it is a local-test tool: Robolectric tests
MUST live in `src/test/`, never in `src/androidTest/`. The official
conversion path says exactly that: an instrumented test becomes a
Robolectric test by moving it to the test source set.

Robolectric setup (both pieces required):

```kotlin
android {
    testOptions { unitTests { isIncludeAndroidResources = true } }
}
dependencies {
    testImplementation("org.robolectric:robolectric:4.13")
}
```

WHY: `androidTest` code needs a device or emulator and runs an order of
magnitude slower. A Robolectric test parked in `androidTest` silently
turns a fast local suite into an instrumentation run.

## 2. Dependency scope — test libs never ship in the APK

MUST declare test-only libraries in the scope of the source set that uses
them: `testImplementation` for local tests (JUnit, Mockito, MockK,
Robolectric), `androidTestImplementation` for instrumented tests
(AndroidX Test core/runner/rules, Espresso, UI Automator). MUST NOT put
them on `implementation`/`api` — that puts the test framework on the
production classpath and ships it in the APK.

WRONG:
```kotlin
implementation("junit:junit:4.13.2")
implementation("io.mockk:mockk:1.13.11")
```

RIGHT:
```kotlin
testImplementation("junit:junit:4.13.2")
testImplementation("io.mockk:mockk:1.13.11")
androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
```

Documented exception: `espresso-idling-resource` may be `implementation`
when production code references it — the set-up-project guide allows both,
depending on whether the dependency belongs on the app or the test APK
classpath.

## 3. Activity rule — no deprecated ActivityTestRule

MUST NOT use `androidx.test.rule.ActivityTestRule` (deprecated). Use
`ActivityScenarioRule` (androidx.test.ext.junit.rules) or `ActivityScenario`
(androidx.test.core.app); to touch the Activity under test use
`scenario.onActivity {}`.

WRONG:
```kotlin
@get:Rule
val rule = ActivityTestRule(LoginActivity::class.java)
```

RIGHT:
```kotlin
@get:Rule
val rule = activityScenarioRule<LoginActivity>()
```

## 4. Synchronization — Espresso tracks idle state

MUST NOT `Thread.sleep` / `SystemClock.sleep` in instrumented tests.
Espresso keeps track of the app under test's idle state (message queue,
AsyncTasks, registered idling resources) and lets you stay away from
waits, syncs, sleeps and polls. For background work Espresso cannot see
(custom threads, network callbacks), register an `IdlingResource` — do
not sleep.

WRONG:
```kotlin
onView(withId(R.id.greet_button)).perform(click())
Thread.sleep(2_000)
onView(withText("Hello Steve!")).check(matches(isDisplayed()))
```

RIGHT:
```kotlin
onView(withId(R.id.greet_button)).perform(click())
onView(withText("Hello Steve!")).check(matches(isDisplayed()))
// synchronization is built in
```

## 5. What the checks cannot see (review-verified)

- Test doubles: prefer fakes over mocks — the official fundamentals
  examples construct the object under test with a fake repository, and
  the local-tests guide says to avoid complex mocking and use fakes
  (or Robolectric shadows) instead.
- Test pyramid balance, CI sharding, parameterized tests — strategy
  decisions, not text patterns.

## Verification

Run after every Android test edit (from the project root):

```bash
bash <skill-dir>/checks/check_robolectric_source_set.sh   <project-or-src-dir>
bash <skill-dir>/checks/check_test_dep_scope.sh           <project-or-src-dir>
bash <skill-dir>/checks/check_no_activity_test_rule.sh    <test-src-dir>
bash <skill-dir>/checks/check_no_sleep_in_instrumented.sh <test-src-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic heuristics — they catch the documented anti-patterns above,
not every testing bug. §5 is verified by review against
references/testing-android.md.
