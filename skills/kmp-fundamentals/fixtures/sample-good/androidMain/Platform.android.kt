package com.example.fixtures

import android.os.Build

// GOOD fixture — androidMain: actual declarations only (with an
// actual typealias for the expect class in commonMain).

actual fun platformName(): String = "Android"
actual fun buildFlavor(): String = Build.TYPE

class AndroidSdk
actual typealias PlatformSdk = AndroidSdk
