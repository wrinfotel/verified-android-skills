# Architecture & state holders — primary sources

Distilled index. Rule text lives in SKILL.md; this file exists so the agent
(and reviewers) can verify every rule against its origin.

1. **Guide to app architecture** — layers (UI / optional domain / data), the
   downward-only dependency rule, single source of truth, unidirectional
   data flow.
   https://developer.android.com/topic/architecture

2. **UI layer** — UI elements + state holders; state flows down, events up;
   events must terminate at the SSOT composable that owns the state holder.
   https://developer.android.com/topic/architecture/ui-layer

3. **State holders and UI state** — screen-level (ViewModel) vs plain
   state-holder classes; "Don't pass ViewModel instances down to other
   composable functions"; business logic before UI logic; lifetime rules
   for each holder kind.
   https://developer.android.com/topic/architecture/ui-layer/stateholders

4. **Compose state** — state hoisting (value down, `onValueChange` up), the
   three hoisting rules, `collectAsStateWithLifecycle()` as the recommended
   collection API on Android, `rememberSaveable`.
   https://developer.android.com/develop/ui/compose/state

5. **Compose side effects** — `LaunchedEffect`, `rememberCoroutineScope`,
   which effect belongs at which layer of composition.
   https://developer.android.com/develop/ui/compose/side-effects

6. **ViewModel overview** — retention across config changes, scoping to
   navigation destinations, `SavedStateHandle`.
   https://developer.android.com/topic/libraries/architecture/viewmodel

7. **Data layer** — repositories as the app-data API the UI must never skip.
   https://developer.android.com/topic/architecture/data-layer

Format precedent (terse, imperative, RIGHT/WRONG pairs, verification
checklist) reviewed from Apache-2.0/MIT projects listed in NOTICE.
