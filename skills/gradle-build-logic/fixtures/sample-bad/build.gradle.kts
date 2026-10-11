// BAD fixture — deliberately trips all four gradle-build-logic checks.
// Never built; smells: hardcoded dependency coordinates, kapt, an
// unminified release build type, and (see gradle.properties beside this
// file) build-speed flags off.

plugins {
    id("com.android.application")
    kotlin("kapt")
}

dependencies {
    implementation("com.example:legacy:1.2.3")
    kapt("com.example:processor:0.9.0")
}

android {
    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}
