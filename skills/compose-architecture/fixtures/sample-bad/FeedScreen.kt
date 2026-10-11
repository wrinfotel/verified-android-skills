package com.example.fixtures

import androidx.compose.foundation.layout.Column
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.ViewModel
import androidx.room.Dao
import com.example.data.FeedRepository
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

// BAD fixture — deliberately trips all four compose-architecture checks.
// Used by verify.sh --selftest to prove the checks fire. It is never
// compiled; the smells are: data-layer imports in a composable file, a
// manually constructed ViewModel, plain collectAsState(), and GlobalScope.

class FeedRepository {
    fun posts(): List<String> = emptyList()
    companion object { val instance = FeedRepository() }
}

class FeedViewModel(private val repository: FeedRepository) : ViewModel() {
    val feed = MutableStateFlow(emptyList<String>())
}

@Composable
fun FeedScreen() {
    val repository = FeedRepository.instance
    val viewModel = FeedViewModel(repository)
    val posts = viewModel.feed.collectAsState().value
    Column {
        Text(posts.firstOrNull().orEmpty())
    }
}

fun preload() {
    GlobalScope.launch { repositoryWarmUp() }
}

private fun repositoryWarmUp() { /* noop */ }
