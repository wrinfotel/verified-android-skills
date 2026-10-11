// BAD fixture — a module with Compose UI tests but no ui-test dependencies.
plugins {
    id("com.android.application")
}

dependencies {
    androidTestImplementation("junit:junit:4.13.2")
    debugImplementation("androidx.compose.ui:ui-tooling:1.9.0")
}
