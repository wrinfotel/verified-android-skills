package com.example.fixtures

import android.content.Context
import androidx.room.Room

// BAD fixture — deliberately triggers offline-first checks.
// Used by verify.sh --selftest to prove the checks fire.

object AppDatabase {
    fun build(context: Context): AppDb =
        Room.databaseBuilder<AppDb>(context, "fixtures.db")
            .allowMainThreadQueries()
            .fallbackToDestructiveMigration()
            .build()
}
