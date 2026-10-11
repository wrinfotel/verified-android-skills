package com.example.fixtures

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel

// BAD fixture — @HiltViewModel without @Inject constructor, and another
// ViewModel injected as a dependency.

@HiltViewModel
class ProfileViewModel(
    private val userViewModel: UserViewModel
) : ViewModel()
