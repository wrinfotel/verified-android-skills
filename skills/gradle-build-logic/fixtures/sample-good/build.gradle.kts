// GOOD fixture — must pass every gradle-build-logic check.
// Version-catalog accessors, KSP, and a fully optimized release build
// type. (gradle.properties beside this file carries the speed flags.)

plugins {
    id("com.android.application")
}

dependencies {
    implementation(libs.example.library)
    ksp(libs.example.processor)
}

android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
