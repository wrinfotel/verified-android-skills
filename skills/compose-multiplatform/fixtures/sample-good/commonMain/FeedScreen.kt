package com.example.fixtures

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import com.example.composeapp.generated.resources.Res
import org.jetbrains.compose.resources.stringResource

// GOOD fixture — must pass every compose-multiplatform check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean
// code: CMP resources (Res + org.jetbrains.compose.resources), no
// Android-only Compose APIs, no Fragments in the common source set.

@Composable
fun FeedScreen() {
    Column {
        Text(text = stringResource(Res.string.feed_title))
    }
}
