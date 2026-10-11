package com.example.fixtures

import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.isDisplayed
import androidx.test.espresso.matcher.ViewMatchers.withText
import androidx.test.rule.ActivityTestRule
import org.junit.Test

// BAD fixture — deliberately triggers android-testing checks.
// Used by verify.sh --selftest to prove the checks fire.

class LoginScreenTest {
    @get:Rule
    val rule = ActivityTestRule(LoginActivity::class.java)

    @Test
    fun greeterSaysHello() {
        Thread.sleep(2_000)
        onView(withText("Hello Steve!")).check(matches(isDisplayed()))
    }
}
