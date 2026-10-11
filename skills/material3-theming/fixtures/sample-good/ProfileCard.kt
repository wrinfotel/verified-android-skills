package com.example.fixtures

import androidx.compose.foundation.background
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

// GOOD fixture — must pass every material3-theming check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.
// Commented hardcodes below are comment-filter regression markers:
// color = Color(0xFF1B6EF3)
// fontSize = 18.sp

@Composable
fun ProfileCard(name: String) {
    Button(onClick = {}) {
        Text(
            text = name,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = Modifier.background(MaterialTheme.colorScheme.surface),
        )
    }
}
