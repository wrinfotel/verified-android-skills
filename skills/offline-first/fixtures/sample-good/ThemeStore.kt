package com.example.fixtures

import android.content.Context
import androidx.datastore.preferences.preferencesDataStore

// GOOD fixture — a different name means a different file: legal.

val Context.themeStore by preferencesDataStore(name = "theme")
