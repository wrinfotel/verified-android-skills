# Compose migration & interop — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Compose in Views** (`ComposeView`, `AbstractComposeView`) —
   `ViewCompositionStrategy` semantics: the default
   (`DisposeOnDetachedFromWindowOrReleasedFromPool`) disposes on window
   detach and "may cause state loss" when incrementally adopting Compose;
   `DisposeOnViewTreeLifecycleDestroyed` for "ComposeView in a Fragment's
   View"; `setViewCompositionStrategy()` to change it; "if there are
   multiple ComposeView elements in the same layout, each one must have a
   unique ID for savedInstanceState to work"; returning a bare
   `ComposeView(requireContext())` from `onCreateView` for fully-Compose
   screens; Fragments are a transitionary step.
   https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views

2. **Views in Compose** (`AndroidView`, `AndroidViewBinding`) — the
   factory lambda creates the view once at instantiation; the `update`
   lambda reruns "when the view's been inflated or state read in this
   block has been updated" (state reads belong in `update`); do not store
   view references outside AndroidView via `remember`; `AndroidViewBinding`
   only for small legacy XML layouts during incremental migration; the
   lazy-container overload with `onReset`/`onRelease` (1.4.0+) for view
   reuse; AndroidView is for SDK components without Compose support.
   https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/views-in-compose

3. **Migration strategy** — incremental migration with Compose and Views
   coexisting; three steps (new features in Compose first, a shared UI
   component library as source of truth, then screen-by-screen); bottom-up
   approach for mixed screens starting with simple screens; Navigation
   Compose only "when you're able to replace all Fragments" with
   screen-level composables; rely on UI testing during migration.
   https://developer.android.com/develop/ui/compose/migrate/strategy

4. **Migration overview hub** — entry point linking all migration and
   interop pages.
   https://developer.android.com/develop/ui/compose/migrate/overview

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
