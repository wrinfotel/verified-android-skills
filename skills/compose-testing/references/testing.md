# Compose testing — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Testing in Compose** — test rules (`createComposeRule()` vs
   `createAndroidComposeRule<YourActivity>()`, "if you need access to an
   activity"), the dependency snippet (`ui-test-junit4` +
   `debugImplementation ui-test-manifest`), semantics as the way tests
   interact with the UI.
   https://developer.android.com/develop/ui/compose/testing

2. **Test synchronization** — the virtual test clock ("Compose tests don't
   run in real time"), automatic synchronization on assertions/actions,
   `waitUntil` helpers (`waitUntilExactlyOneExists`,
   `waitUntilNodeCount`, ...), `mainClock.autoAdvance` /
   `advanceTimeBy` / `advanceTimeByFrame`, `waitForIdle` semantics, the
   warning that external blocking (e.g. a `CountDownLatch`) "could behave
   unexpectedly, since the test clock won't be advanced", and idling
   resources for background work.
   https://developer.android.com/develop/ui/compose/testing/synchronization

3. **Testing cheatsheet** — quick reference of finders, assertions,
   actions, and synchronization APIs.
   https://developer.android.com/develop/ui/compose/testing/testing-cheatsheet

4. **Semantics in Compose** — the semantics tree that matchers like
   `onNodeWithText` / `onNodeWithTag` operate on; how to add
   `testTag` / `contentDescription` meaningfully.
   https://developer.android.com/develop/ui/compose/semantics

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
