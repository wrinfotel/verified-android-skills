---
name: compose-migration
description: >
  Interop and incremental migration between Android Views and Jetpack
  Compose: ComposeView lifecycle strategy in Fragments, AndroidView
  factory/update split, XML layout interop, and migration ordering.
  Use when embedding composables in View hierarchies, wrapping legacy
  views, or planning a View-to-Compose migration. Core rules have machine
  checks in checks/.
version: 0.1.0
---

# Compose Migration

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY interop or migration edit, run the Verification step (bottom of
this file).

## 1. ComposeView in Fragments — set the composition strategy

MUST set
`setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)`
on every ComposeView used inside a Fragment, so the composition disposes
with the Fragment's view lifecycle. The default strategy
(`DisposeOnDetachedFromWindowOrReleasedFromPool`) disposes on window
detach and may cause state loss during incremental migration.

WRONG:
```kotlin
class ProfileFragment : Fragment() {
    override fun onCreateView(...): View =
        ComposeView(requireContext())
            .apply { setContent { ProfileScreen() } }
}
```

RIGHT:
```kotlin
class ProfileFragment : Fragment() {
    override fun onCreateView(...): View =
        ComposeView(requireContext()).apply {
            setViewCompositionStrategy(
                ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed
            )
            setContent { ProfileScreen() }
        }
}
```

Fragments are a transitionary step: Compose-only screens belong in a
single-Activity architecture without Fragments.

## 2. AndroidView — factory creates once, update reads state

MUST keep the `factory` lambda pure: create the view and nothing else —
it runs once at instantiation, so state read there goes stale. MUST read
Compose state in `update`, which reruns whenever the state it reads
changes. MUST NOT hold view references outside AndroidView via
`remember`.

WRONG:
```kotlin
AndroidView(
    factory = { context ->
        TextView(context).apply { text = count.value.toString() }  // stale
    },
)
```

RIGHT:
```kotlin
AndroidView(
    factory = { context -> TextView(context) },
    update = { view -> view.text = count.value.toString() },
)
```

Reach for AndroidView only for SDK components without a Compose
counterpart (ads, maps, WebView); custom views are better rewritten as
composables. In lazy lists and pagers use the AndroidView overload with
`onReset` (1.4.0+) so the underlying view instance is reused.

## 3. XML interop — unique IDs for multiple ComposeViews

When a layout hosts more than one ComposeView, each MUST have a unique
`android:id`, or savedInstanceState restoration breaks.

WRONG:
```xml
<androidx.compose.ui.platform.ComposeView android:layout_width="match_parent" />
<androidx.compose.ui.platform.ComposeView android:layout_width="match_parent" />
```

RIGHT:
```xml
<androidx.compose.ui.platform.ComposeView android:id="@+id/header_compose" ... />
<androidx.compose.ui.platform.ComposeView android:id="@+id/body_compose" ... />
```

Embed legacy XML during migration via `AndroidViewBinding`
(`androidx.compose.ui:ui-viewbinding`) — for small legacy layouts only,
never for full screens.

## 4. Migration order (review-verified)

- New features and screens: Compose first — ComposeView in the Fragment's
  `onCreateView` with the strategy above while navigation is still
  Fragment-based.
- Existing screens: migrate bottom-up — reusable leaf elements first,
  building a shared component library as the source of truth, one screen
  at a time; start with simple screens.
- Navigation: move to Navigation Compose only after all Fragments are
  replaced by screen-level composables; keep Fragment navigation until
  then.
- Rely on UI tests across migration steps to catch regressions.

No deterministic check covers ordering; verify against
references/migration.md.

## Verification

Run after every interop or migration edit (from the project root):

```bash
bash <skill-dir>/checks/check_composeview_fragment_strategy.sh <src-dir>
bash <skill-dir>/checks/check_androidview_factory_state.sh     <src-dir>
bash <skill-dir>/checks/check_composeview_ids_in_xml.sh        <res-or-src-dir>
```

All three must pass (exit 0) before declaring the task done. Checks are
deterministic file-level heuristics — they catch the documented
anti-patterns above, not every migration bug. Ordering (§4) is verified
by review against references/migration.md.
