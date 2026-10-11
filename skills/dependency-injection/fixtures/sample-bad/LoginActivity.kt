package com.example.fixtures

import androidx.appcompat.app.AppCompatActivity
import javax.inject.Inject

// BAD fixture — deliberately triggers dependency-injection checks.
// Used by verify.sh --selftest to prove the checks fire.

class LoginActivity : AppCompatActivity() {
    @Inject
    lateinit var loginRepository: LoginRepository
}
