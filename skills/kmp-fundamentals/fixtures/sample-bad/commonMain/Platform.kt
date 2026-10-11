package com.example.fixtures

import android.content.Context

// BAD fixture — deliberately trips all three kmp-fundamentals checks.
// Never compiled; smells: a platform SDK import in commonMain, an actual
// declaration in commonMain, and expect declarations without any actual
// (PlatformSdk, buildFlavor below have no actual anywhere in this module;
// androidMain declares an expect that belongs in commonMain).

expect fun platformName(): String
expect fun buildFlavor(): String
expect class PlatformSdk

actual fun logTag(): String = "shared"
