package com.example.fixtures

import androidx.compose.runtime.Composable
import androidx.compose.ui.test.assertDoesNotExist
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.setContent
import androidx.test.ext.junit.rules.ActivityScenarioRule
import kotlinx.coroutines.delay
import org.junit.Rule
import org.junit.Test

// BAD fixture — deliberately trips all three compose-testing checks.
// Never compiled; smells: Thread.sleep / delay synchronization,
// ActivityScenarioRule paired with a ComposeTestRule, and Compose UI
// tests without ui-test dependencies (see the build.gradle.kts beside
// this file).

class MainActivity : androidx.activity.ComponentActivity()

@Composable
private fun Feed() { }

class FeedTest {
    @get:Rule
    val composeRule = createComposeRule()

    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun feedLoads() {
        composeRule.setContent { Feed() }
        Thread.sleep(2_000)
        composeRule.onNodeWithText("Done").assertIsDisplayed()
    }

    @Test
    fun spinnerStops() {
        composeRule.mainClock.autoAdvance = false
        delay(1_000)
        composeRule.onNodeWithTag("spinner").assertDoesNotExist()
    }
}
