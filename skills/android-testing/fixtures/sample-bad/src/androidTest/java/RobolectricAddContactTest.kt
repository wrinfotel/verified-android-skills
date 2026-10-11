package com.example.fixtures

import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

// BAD fixture — Robolectric test placed in the instrumented source set.
// Robolectric runs in a JVM; this file belongs in src/test.

@RunWith(RobolectricTestRunner::class)
class AddContactTest {
    @Test
    fun inputRetained() {
        // ...
    }
}
