package com.example.fixtures

import androidx.compose.runtime.Immutable
import kotlinx.collections.immutable.ImmutableList

// GOOD fixture — must pass every compose-performance check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

@Immutable
data class CounterUi(
    val label: String,
    val count: Int,
    val history: ImmutableList<Int>,
)

@Composable
fun Counter(state: CounterUi, onSelect: (Int) -> Unit) {
    Text(state.label)
}
