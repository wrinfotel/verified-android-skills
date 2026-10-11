package com.example.fixtures

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

// GOOD fixture — Robolectric in src/test, where it belongs (JVM, no device).
// ApplicationProvider comes from androidx.test:core (testImplementation scope).

@RunWith(RobolectricTestRunner::class)
class AddContactTest {
    @Test
    fun inputRetained() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        // ...
    }
}
