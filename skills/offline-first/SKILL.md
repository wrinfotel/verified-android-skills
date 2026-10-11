---
name: offline-first
description: >
  Offline-first Android data discipline: the local source as the single
  source of truth, repositories as the only data-layer entry point, Room
  without main-thread access, migrations instead of destructive fallback,
  and one DataStore instance per file. Use when writing or reviewing
  repositories, Room databases, DataStore delegates, or sync workers.
  Core rules have machine checks in checks/.
version: 0.1.0
---

# Offline-First

Operational rules for a coding agent. RIGHT/WRONG pairs are canonical.
After ANY data-layer edit, run the Verification step (bottom of this file).

## 1. The local source is the single source of truth

MUST structure offline-first reads around a local source of truth
(a database): repositories expose data as observable types (Flow) read
from the local source, and writes go to the local source first, then sync
to the network. "An offline-first app must be able to perform read
operations without network access."

MUST NOT let state holders touch data sources directly: other layers
"should not access data sources directly. The entry points to the data
layer are always repository classes" — state holders (ViewModels)
"should never have a direct dependency on a data source". The domain and
UI layers must never communicate directly with the network layer.

WRONG:
```kotlin
@HiltViewModel
class FeedViewModel @Inject constructor() : ViewModel() {
    private val api = Retrofit.Builder()
        .baseUrl("https://example.com/")
        .build()                          // network source in a state holder
}
```

RIGHT:
```kotlin
@HiltViewModel
class FeedViewModel @Inject constructor(
    private val feedRepository: FeedRepository,   // Flow from the local DB
) : ViewModel()
```

The check flags data-source imports (Retrofit, OkHttp, Ktor, Room,
DataStore) inside ViewModel files. Repositories are exempt — they ARE the
data layer.

## 2. Room never runs on the main thread

MUST NOT call `allowMainThreadQueries()`: "To prevent queries from
blocking the UI, Room does not support database access on the main
thread" — the builder escape hatch reintroduces exactly the jank and ANR
Room exists to prevent. DAOs expose `suspend` functions for one-shot
operations and `Flow` for observable queries, executed from coroutines.

WRONG:
```kotlin
Room.databaseBuilder<AppDb>(context, "app.db")
    .allowMainThreadQueries()
    .build()
```

RIGHT:
```kotlin
Room.databaseBuilder<AppDb>(context, "app.db").build()
// @Dao: suspend fun loadUserById(id: Int): User
//       fun loadUsers(): Flow<List<User>>
```

## 3. Migrations, not destruction

MUST NOT ship `fallbackToDestructiveMigration()`: when a migration is
needed and no path is defined, Room "permanently deletes all data from
the app's database tables" — silent user-data loss on every schema bump.
Provide `Migration(startVersion, endVersion)` objects via
`addMigrations(...)`. The targeted variants
(`fallbackToDestructiveMigrationFrom` / `...OnDowngrade`) are the
documented tools for deliberately scoped rebuilds — the check flags only
the blanket option.

WRONG:
```kotlin
Room.databaseBuilder<AppDb>(context, "app.db")
    .fallbackToDestructiveMigration()
    .build()
```

RIGHT:
```kotlin
val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("ALTER TABLE Book ADD COLUMN pub_year INTEGER")
    }
}
Room.databaseBuilder<AppDb>(context, "app.db")
    .addMigrations(MIGRATION_1_2)
    .build()
```

## 4. One DataStore instance per file

MUST NOT create more than one DataStore instance for a given file in the
same process: "Doing so can break all DataStore functionality... DataStore
will throw IllegalStateException when reading or updating data." Each
`preferencesDataStore(name = ...)` delegate maps to a file — names must be
unique across the app.

WRONG:
```kotlin
// SettingsStore.kt
val Context.settingsStore by preferencesDataStore(name = "settings")
// ProfileStore.kt
val Context.profileStore by preferencesDataStore(name = "settings")  // same file!
```

RIGHT:
```kotlin
// SettingsStore.kt
val Context.settingsStore by preferencesDataStore(name = "settings")
// ThemeStore.kt
val Context.themeStore by preferencesDataStore(name = "theme")
```

DataStore is for small datasets: "If you need to support large or complex
datasets, partial updates, or referential integrity, consider using Room
instead."

## 5. What the checks cannot see (review-verified)

- Sync strategy: queued/lazy writes with WorkManager ("persistent work"
  is what it is for) — unique work with `ExistingWorkPolicy.KEEP`, a
  network constraint, and `Result.retry()` for automatic exponential
  backoff.
- Conflict resolution (last-write-wins timestamps) and LCE UI states
  (Loading / Content / Error) around offline reads.
- SharedPreferences are legacy: "If you're using SharedPreferences to
  store data, consider migrating to DataStore instead."

## Verification

Run after every data-layer edit (from the project root):

```bash
bash <skill-dir>/checks/check_no_data_source_in_viewmodel.sh <kotlin-src-dir>
bash <skill-dir>/checks/check_room_allow_main_thread.sh      <kotlin-src-dir>
bash <skill-dir>/checks/check_room_fallback_destructive.sh   <kotlin-src-dir>
bash <skill-dir>/checks/check_datastore_dup_names.sh         <kotlin-src-dir>
```

All four must pass (exit 0) before declaring the task done. Checks are
deterministic heuristics — they catch the documented anti-patterns above,
not every offline-first bug. §5 is verified by review against
references/offline-first.md.
