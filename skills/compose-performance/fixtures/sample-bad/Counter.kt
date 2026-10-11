package com.example.fixtures

// BAD fixture — deliberately triggers all three compose-performance checks.
// Used by verify.sh --selftest to prove the checks fire.

data class CounterUi(val label: String, var count: Int)

@Composable
fun Counter(state: CounterUi, items: MutableList<String>) {
    val history = remember { mutableListOf<Int>() }
    Text(state.label)
}
