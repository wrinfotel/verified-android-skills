plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.fixtures"
    compileSdk = 35
}

dependencies {
    // BAD fixture — three test-only libraries on the production classpath.
    implementation("junit:junit:4.13.2")
    implementation("io.mockk:mockk:1.13.11")
    implementation("androidx.test:core:1.6.1")

    // Correct scopes mixed in — must NOT be flagged.
    testImplementation("org.robolectric:robolectric:4.13")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}
