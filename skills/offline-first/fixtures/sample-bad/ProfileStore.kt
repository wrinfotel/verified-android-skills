package com.example.fixtures

import android.content.Context
import androidx.datastore.preferences.preferencesDataStore

// BAD fixture — second delegate for the SAME "settings" file: two DataStore
// instances for one file break all DataStore functionality.

val Context.profileStore by preferencesDataStore(name = "settings")
