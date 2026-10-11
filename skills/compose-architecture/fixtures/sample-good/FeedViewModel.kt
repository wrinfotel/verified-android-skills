package com.example.fixtures

import androidx.lifecycle.ViewModel
import kotlinx.collections.immutable.persistentListOf
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class FeedUiState(val messages: ImmutableList<String> = persistentListOf())

// A plain ViewModel class must NOT trip check_viewmodel_construction:
// only `= FooViewModel(...)` call sites are flagged, never declarations.

class FeedViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(FeedUiState())
    val uiState: StateFlow<FeedUiState> = _uiState.asStateFlow()

    fun open(id: String) { /* route via an event callback in real code */ }
}
