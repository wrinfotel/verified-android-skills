package com.example.fixtures

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

// GOOD fixture — @HiltViewModel with constructor injection; the dependency
// is a repository, not another ViewModel.

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val userRepository: UserRepository
) : ViewModel()
