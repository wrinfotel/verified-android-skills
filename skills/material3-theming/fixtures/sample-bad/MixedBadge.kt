package com.example.fixtures

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

// BAD fixture — an M3 file still reading the M2 theme accessor: compiles
// when M2 is on the classpath but reads the wrong theme.

@Composable
fun MixedBadge() {
    Text("hi", color = MaterialTheme.colors.primary)
}
