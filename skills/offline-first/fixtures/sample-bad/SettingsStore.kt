package com.example.fixtures

import android.content.Context
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.preferencesDataStore

// BAD fixture — first delegate for the "settings" file.

val Context.settingsStore by preferencesDataStore(name = "settings")
