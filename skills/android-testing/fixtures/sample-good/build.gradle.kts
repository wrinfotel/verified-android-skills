plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.fixtures"
    compileSdk = 35
}

dependencies {
    // GOOD fixture — every test-only library in its proper scope.
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.11")
    testImplementation("org.robolectric:robolectric:4.13")
    androidTestImplementation("androidx.test:core:1.6.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")

    // Documented exception (set-up-project): production code references the
    // idling-resource API, so implementation scope is allowed here.
    implementation("androidx.test.espresso:espresso-idling-resource:3.6.1")
}
