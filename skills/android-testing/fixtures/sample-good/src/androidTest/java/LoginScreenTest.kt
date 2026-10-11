package com.example.fixtures

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.ext.junit.rules.activityScenarioRule
import org.junit.Rule
import org.junit.Test

// GOOD fixture — must pass every android-testing check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

class LoginScreenTest {
    // activityScenarioRule replaces the deprecated ActivityTestRule (comment kept
    // as a comment-filter regression marker; must not flag).
    @get:Rule
    val rule = activityScenarioRule<LoginActivity>()

    @Test
    fun greeterSaysHello() {
        onView(withText("Hello Steve!")).check(matches(isDisplayed()))
    }
}
