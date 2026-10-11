package com.example.fixtures

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import kotlinx.collections.immutable.ImmutableList

// GOOD fixture — must pass every compose-architecture check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

@Composable
fun FeedScreen(viewModel: FeedViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    Column {
        FeedList(messages = uiState.messages, onOpen = viewModel::open)
    }
}

@Composable
fun FeedList(messages: ImmutableList<String>, onOpen: (String) -> Unit) {
    Column {
        messages.forEach { message ->
            Text(text = message)
        }
    }
}
