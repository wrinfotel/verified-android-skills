package com.example.fixtures

import android.content.Context
import androidx.datastore.preferences.preferencesDataStore

// GOOD fixture — unique DataStore names. The commented delegate below is a
// comment-filter regression marker; it must not count as a duplicate.
// val Context.oldStore by preferencesDataStore(name = "settings")

val Context.settingsStore by preferencesDataStore(name = "settings")
