// GOOD fixture — Compose UI test dependencies declared correctly.
plugins {
    id("com.android.application")
}

dependencies {
    androidTestImplementation("androidx.compose.ui:ui-test-junit4:1.9.0")
    debugImplementation("androidx.compose.ui:ui-test-manifest:1.9.0")
}
