package com.example.fixtures

import androidx.compose.foundation.background
import androidx.compose.material.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.unit.sp

// BAD fixture — deliberately triggers material3-theming checks.
// Used by verify.sh --selftest to prove the checks fire.

@Composable
fun ProfileCard(name: String) {
    Button(onClick = {}) {
        Text(
            text = name,
            color = Color(0xFF1B6EF3),
            fontSize = 18.sp,
        )
    }
}

@Composable
fun Banner() {
    Text(
        text = "Sale",
        color = colorResource(R.color.accent),
        modifier = Modifier.background(Color(0xFFEEEEEE)),
    )
}
