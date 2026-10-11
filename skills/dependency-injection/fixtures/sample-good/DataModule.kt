package com.example.fixtures

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

// GOOD fixture — @Provides inside a @Module installed in SingletonComponent.

@Module
@InstallIn(SingletonComponent::class)
object DataModule {
    @Singleton
    @Provides
    fun provideAnalyticsService(): AnalyticsService = AnalyticsServiceImpl()
}
