package com.example.fixtures

import androidx.appcompat.app.AppCompatActivity
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

// GOOD fixture — must pass every dependency-injection check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

@AndroidEntryPoint
class LoginActivity : AppCompatActivity() {
    // @Inject lateinit var legacy: LegacyRepository (comment kept as a
    // comment-filter regression marker; must not flag).
    @Inject
    lateinit var loginRepository: LoginRepository
}
