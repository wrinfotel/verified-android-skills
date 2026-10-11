package com.example.fixtures

import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import androidx.compose.ui.test.assertDoesNotExist
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import org.junit.Rule
import org.junit.Test

// GOOD fixture — must pass every compose-testing check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

object TestTags { const val Spinner = "spinner" }

class MainActivity : ComponentActivity()

@Composable
private fun Feed() {
    Column { }
}

class FeedTest {
    @get:Rule
    val composeRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun feedLoads() {
        composeRule.setContent { Feed() }
        composeRule.waitUntilExactlyOneExists(hasText("Done"), timeoutMillis = 5_000)
        composeRule.onNodeWithText("Done").assertIsDisplayed()
    }

    @Test
    fun spinnerStopsAfterOneSecond() {
        composeRule.mainClock.autoAdvance = false
        composeRule.mainClock.advanceTimeBy(1_000)
        composeRule.onNodeWithTag(TestTags.Spinner).assertDoesNotExist()
    }
}
