package com.example.fixtures

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.fixtures.data.FeedRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

// GOOD fixture — state holder reads through a repository (offline-first
// Flow from the local source of truth).

@HiltViewModel
class FeedViewModel @Inject constructor(
    feedRepository: FeedRepository,
) : ViewModel() {
    val feed: StateFlow<List<String>> = feedRepository.feedStream()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000),
            initialValue = emptyList(),
        )
}
