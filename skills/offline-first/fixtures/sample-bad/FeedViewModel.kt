package com.example.fixtures

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import retrofit2.Retrofit

// BAD fixture — a state holder building its own network source instead of
// reading through a repository.

@HiltViewModel
class FeedViewModel @Inject constructor() : ViewModel() {
    private val api = Retrofit.Builder()
        .baseUrl("https://example.com/")
        .build()
}
