package com.example.fixtures

// GOOD fixture — common source set: expect declarations only, no platform
// SDK imports. Used by verify.sh --selftest to prove the checks stay quiet
// on clean code. Every expect below has actuals in androidMain and iosMain.

expect fun platformName(): String
expect fun buildFlavor(): String
expect class PlatformSdk
