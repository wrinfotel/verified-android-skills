package com.example.fixtures

import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Test

// GOOD fixture — plain JVM test: no androidx.test imports, test doubles via MockK.

class UserRepositoryTest {
    @Test
    fun loadsUser() {
        val repo = UserRepository(mockk())
        assertEquals("Ada", repo.name())
    }
}
