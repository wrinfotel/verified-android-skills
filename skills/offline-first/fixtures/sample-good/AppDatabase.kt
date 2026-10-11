package com.example.fixtures

import android.content.Context
import androidx.room.Room
import androidx.sqlite.db.SupportSQLiteDatabase

// GOOD fixture — must pass every offline-first check.
// Used by verify.sh --selftest to prove the checks stay quiet on clean code.

object AppDatabase {
    fun build(context: Context): AppDb {
        val MIGRATION_1_2 = object : androidx.room.migration.Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("ALTER TABLE Book ADD COLUMN pub_year INTEGER")
            }
        }
        return Room.databaseBuilder<AppDb>(context, "fixtures.db")
            .addMigrations(MIGRATION_1_2)
            .build()
    }
}
