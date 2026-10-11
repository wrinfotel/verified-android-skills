package com.example.fixtures

import javax.inject.Singleton

// BAD fixture — @Provides outside a @Module (class not annotated).

class DataModule {
    @Singleton
    @Provides
    fun provideAnalyticsService(): AnalyticsService = AnalyticsServiceImpl()
}
