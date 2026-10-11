package com.example.fixtures

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.fragment.app.Fragment
import com.example.app.R

// BAD fixture — deliberately trips all three compose-multiplatform checks.
// Never compiled; smells: Android R-class resources, Android-only Compose
// APIs (LocalContext, androidx.compose.ui.res), and a Fragment class
// inside a common source set.

@Composable
fun FeedScreen() {
    val context = LocalContext.current
    Column {
        Text(text = stringResource(R.string.feed_title))
    }
}

class FeedFragment : Fragment()
