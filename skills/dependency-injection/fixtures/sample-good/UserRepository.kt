package com.example.fixtures

import javax.inject.Inject

// GOOD fixture — plain constructor injection: no fields, no entry point needed.

class UserRepository @Inject constructor(
    private val api: UserApi,
)
