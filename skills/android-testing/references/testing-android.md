# Android testing — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Test fundamentals** — local (host-side) tests vs instrumented tests on
   a device/emulator; Robolectric named as a locally-running Android
   simulator ("large local test"); "not every unit test is local, and not
   every end-to-end test runs on a device".
   https://developer.android.com/training/testing/fundamentals

2. **Project setup** — AndroidX Test artifacts (core, runner, rules,
   ext:junit, ext:truth) and Espresso declared with
   `androidTestImplementation`; documented exception: the
   `espresso-idling-resource` dependency "can be either implementation, or
   androidTestImplementation, depending on whether you want the dependency
   to appear on your APK's compile classpath or the test APK classpath".
   https://developer.android.com/training/testing/set-up-project

3. **Local unit tests** — source files placed in `module-name/src/test/`;
   `testImplementation` for JUnit 4, Mockito, mockito-kotlin, MockK and the
   Robolectric environment (`androidx.test:core`); "use testImplementation
   ... for the local test source set, not the app".
   https://developer.android.com/training/testing/local-tests

4. **Robolectric** — "run tests in a simulated Android environment inside a
   JVM, without the overhead and flakiness of an emulator"; conversion
   path: "You can convert an instrumented test to Robolectric by moving it
   to the test source set and setting up the Robolectric dependencies";
   requires `testOptions { unitTests.isIncludeAndroidResources = true }`.
   https://developer.android.com/training/testing/local-tests/robolectric

5. **Espresso** — automatic synchronization with the app under test's idle
   state (message queue, AsyncTasks, developer-defined idling resources):
   the framework "lets you stay away from waits, syncs, sleeps and polls";
   background work outside its view is synchronized via idling resources.
   https://developer.android.com/training/testing/espresso

6. **ActivityTestRule is @Deprecated** — source KDoc: "use
   androidx.test.core.app.ActivityScenario or
   androidx.test.ext.junit.rules.ActivityScenarioRule instead. They offer
   a simpler, and safer way of controlling Activity lifecycles."
   https://github.com/android/android-test/blob/main/runner/rules/java/androidx/test/rule/ActivityTestRule.java

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
