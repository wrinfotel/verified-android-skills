plugins {
    id("com.android.application")
}

android {
    namespace = "com.example.fixtures"
    compileSdk = 35

    buildTypes {
        release {
            isDebuggable = true
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
