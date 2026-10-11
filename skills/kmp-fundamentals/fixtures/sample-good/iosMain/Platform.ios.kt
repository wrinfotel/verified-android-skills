package com.example.fixtures

import platform.UIKit.UIDevice

// GOOD fixture — iosMain: actual declarations only. The platform.UIKit
// import is correct here (a platform source set), and must NOT trip
// check_no_platform_imports_in_common.

actual fun platformName(): String = UIDevice.currentDevice.systemName()
actual fun buildFlavor(): String = "ios"

class IosSdk
actual typealias PlatformSdk = IosSdk
