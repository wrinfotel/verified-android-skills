---
name: compose-architecture
description: >
  Jetpack Compose architecture discipline: layer separation, unidirectional
  data flow, ViewModel construction and coroutine scopes, lifecycle-aware
  state collection. Use when creating screens, wiring state holders to
  composables, or reviewing UI-layer structure. Core rules have machine
  checks in checks/.
version: 0.1.0
---

# Compose Architecture

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY screen or state-holder edit, run the Verification step (bottom
of this file).

## 1. Layer separation

MUST read UI state from a state holder: a ViewModel for screen UI state, a
`@Stable` plain class for UI logic. MUST NOT import or call the data layer
(Room DAOs, Retrofit services, DataStore, `*Repository`) from any file that
declares a `@Composable`.

WRONG:
```kotlin
@Composable
fun FeedScreen() {
    val posts = remember { postsRepository.posts() }   // data layer in UI
}
```

RIGHT:
```kotlin
@Composable
fun FeedScreen(viewModel: FeedViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
}
```

WHY: dependencies point downward only (UI → state holder → domain → data).
A composable that reaches into the data layer bypasses the single source of
truth, loses config-change retention, and cannot be previewed or unit-tested.

## 2. Unidirectional data flow

MUST pass child composables plain state + event lambdas. MUST NOT pass a
ViewModel instance down into a reusable composable ("Don't pass ViewModel
instances down to other composable functions" — official guidance, see
references/architecture.md #3).

WRONG:
```kotlin
@Composable
fun Feed(viewModel: FeedViewModel) {
    FeedItem(item = viewModel.selected, onClick = { viewModel.toggle() })
}
```

RIGHT:
```kotlin
@Composable
fun Feed(uiState: FeedUiState, onToggle: (String) -> Unit) {
    FeedItem(item = uiState.selected, onClick = { onToggle(uiState.id) })
}
```

Events travel up to the screen-level composable that owns the ViewModel;
that composable is the single source of truth for handling the event.

## 3. ViewModel construction & coroutine scopes

MUST obtain ViewModels via `viewModel()` / `hiltViewModel()` (or DI scoped
with `SavedStateHandle`). MUST NOT construct one inside a composable — a
manual `FooViewModel()` call creates a fresh instance per composition, with
no retention and no sharing.

WRONG:
```kotlin
val viewModel = FeedViewModel()
```

RIGHT:
```kotlin
val viewModel: FeedViewModel = viewModel()
```

MUST NOT use `GlobalScope` in UI code — its lifetime is unmanaged and
outlives the screen. Use `rememberCoroutineScope()` inside event callbacks
and `LaunchedEffect(key)` for effects keyed to composition.

WRONG:
```kotlin
GlobalScope.launch { analytics.logOpen(screen) }
```

RIGHT:
```kotlin
LaunchedEffect(Unit) { analytics.logOpen(screen) }
```

## 4. Lifecycle-aware state collection

MUST collect state-holder flows with `collectAsStateWithLifecycle()`
(`androidx.lifecycle:lifecycle-runtime-compose`). Plain `collectAsState()`
keeps collecting while the UI is stopped, wasting resources.

WRONG:
```kotlin
val uiState by viewModel.uiState.collectAsState()
```

RIGHT:
```kotlin
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```

Plain `collectAsState()` is allowed only in KMP-common code where the
Android lifecycle API is unavailable; leave a comment at the call site.

## Verification

Run after every screen or state-holder edit (from the project root):

```bash
bash <skill-dir>/checks/check_no_data_layer_in_ui.sh        <src-dir>
bash <skill-dir>/checks/check_viewmodel_construction.sh     <src-dir>
bash <skill-dir>/checks/check_no_global_scope.sh            <src-dir>
bash <skill-dir>/checks/check_collect_as_state_lifecycle.sh <src-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic import/call-site heuristics — they catch the documented
anti-patterns above, not every architecture violation. The parameter shape
of §2 is verified by review against references/architecture.md.
